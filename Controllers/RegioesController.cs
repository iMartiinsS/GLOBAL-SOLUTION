using AlagAlerta.Api.Data;
using AlagAlerta.Api.Dtos;
using AlagAlerta.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AlagAlerta.Api.Controllers;

[ApiController]
[Route("api/regioes")]
[Produces("application/json")]
public class RegioesController : ControllerBase
{
    private readonly AppDbContext _db;

    public RegioesController(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>GET /api/regioes — lista todas as regiões com a quantidade de sensores.</summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<RegiaoResponse>>> Listar()
    {
        var regioes = await _db.Regioes
            .AsNoTracking()
            .Include(r => r.Sensores)
            .OrderBy(r => r.Cidade).ThenBy(r => r.Nome)
            .ToListAsync();
        return Ok(regioes.Select(RegiaoResponse.De));
    }

    /// <summary>GET /api/regioes/{id} — região com os sensores instalados.</summary>
    [HttpGet("{id:int}")]
    public async Task<ActionResult<RegiaoDetalheResponse>> BuscarPorId(int id)
    {
        var regiao = await _db.Regioes
            .AsNoTracking()
            .Include(r => r.Sensores)
            .FirstOrDefaultAsync(r => r.Id == id);

        if (regiao is null)
        {
            return NotFound(new ErroResponse(404, $"Região {id} não encontrada"));
        }
        return Ok(RegiaoDetalheResponse.De(regiao));
    }

    /// <summary>POST /api/regioes — cadastra região (201 + Location).</summary>
    [HttpPost]
    public async Task<ActionResult<RegiaoResponse>> Criar([FromBody] RegiaoRequest req)
    {
        if (await NomeDuplicado(req, idAtual: null))
        {
            return Conflict(new ErroResponse(409, $"Já existe a região '{req.Nome}' em {req.Cidade}"));
        }

        var regiao = new Regiao
        {
            Nome = req.Nome.Trim(),
            Cidade = req.Cidade.Trim(),
            Uf = req.Uf,
            PopulacaoRisco = req.PopulacaoRisco,
            CriadaEm = DateTime.Now
        };
        _db.Regioes.Add(regiao);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(BuscarPorId), new { id = regiao.Id }, RegiaoResponse.De(regiao));
    }

    /// <summary>PUT /api/regioes/{id} — atualiza todos os campos (204).</summary>
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Atualizar(int id, [FromBody] RegiaoRequest req)
    {
        var regiao = await _db.Regioes.FindAsync(id);
        if (regiao is null)
        {
            return NotFound(new ErroResponse(404, $"Região {id} não encontrada"));
        }
        if (await NomeDuplicado(req, idAtual: id))
        {
            return Conflict(new ErroResponse(409, $"Já existe a região '{req.Nome}' em {req.Cidade}"));
        }

        regiao.Nome = req.Nome.Trim();
        regiao.Cidade = req.Cidade.Trim();
        regiao.Uf = req.Uf;
        regiao.PopulacaoRisco = req.PopulacaoRisco;
        await _db.SaveChangesAsync();

        return NoContent();
    }

    /// <summary>DELETE /api/regioes/{id} — remove região sem sensores (204).</summary>
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Excluir(int id)
    {
        var regiao = await _db.Regioes.FindAsync(id);
        if (regiao is null)
        {
            return NotFound(new ErroResponse(404, $"Região {id} não encontrada"));
        }
        if (await _db.Sensores.AnyAsync(s => s.RegiaoId == id))
        {
            return Conflict(new ErroResponse(409, "Região possui sensores. Exclua ou transfira os sensores antes."));
        }

        _db.Regioes.Remove(regiao);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    private Task<bool> NomeDuplicado(RegiaoRequest req, int? idAtual)
    {
        var nome = req.Nome.Trim().ToUpper();
        var cidade = req.Cidade.Trim().ToUpper();
        return _db.Regioes.AnyAsync(r =>
            r.Nome.ToUpper() == nome && r.Cidade.ToUpper() == cidade && (idAtual == null || r.Id != idAtual));
    }
}
