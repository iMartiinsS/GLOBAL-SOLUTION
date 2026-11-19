using AlagAlerta.Api.Data;
using AlagAlerta.Api.Dtos;
using AlagAlerta.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AlagAlerta.Api.Controllers;

[ApiController]
[Route("api/sensores")]
[Produces("application/json")]
public class SensoresController : ControllerBase
{
    private readonly AppDbContext _db;

    public SensoresController(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>GET /api/sensores?regiaoId= — lista sensores, opcionalmente de uma região.</summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<SensorResponse>>> Listar([FromQuery] int? regiaoId)
    {
        var query = _db.Sensores.AsNoTracking().Include(s => s.Regiao).AsQueryable();
        if (regiaoId is not null)
        {
            query = query.Where(s => s.RegiaoId == regiaoId);
        }
        var sensores = await query.OrderBy(s => s.Codigo).ToListAsync();
        return Ok(sensores.Select(SensorResponse.De));
    }

    /// <summary>GET /api/sensores/{id}</summary>
    [HttpGet("{id:int}")]
    public async Task<ActionResult<SensorResponse>> BuscarPorId(int id)
    {
        var sensor = await _db.Sensores.AsNoTracking().Include(s => s.Regiao).FirstOrDefaultAsync(s => s.Id == id);
        if (sensor is null)
        {
            return NotFound(new ErroResponse(404, $"Sensor {id} não encontrado"));
        }
        return Ok(SensorResponse.De(sensor));
    }

    /// <summary>POST /api/sensores — instala sensor em uma região existente (201 + Location).</summary>
    [HttpPost]
    public async Task<ActionResult<SensorResponse>> Criar([FromBody] SensorRequest req)
    {
        var regiao = await _db.Regioes.FindAsync(req.RegiaoId);
        if (regiao is null)
        {
            ModelState.AddModelError(nameof(req.RegiaoId), $"regiaoId {req.RegiaoId} não existe");
            return ValidationProblem(ModelState);
        }
        if (await _db.Sensores.AnyAsync(s => s.Codigo == req.Codigo))
        {
            return Conflict(new ErroResponse(409, $"Já existe sensor com o código {req.Codigo}"));
        }

        var sensor = new Sensor
        {
            Codigo = req.Codigo,
            Localizacao = req.Localizacao.Trim(),
            NivelAlertaCm = req.NivelAlertaCm,
            NivelCriticoCm = req.NivelCriticoCm,
            UltimoNivelCm = req.UltimoNivelCm,
            Status = req.Status,
            InstaladoEm = DateTime.Now,
            RegiaoId = req.RegiaoId,
            Regiao = regiao
        };
        _db.Sensores.Add(sensor);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(BuscarPorId), new { id = sensor.Id }, SensorResponse.De(sensor));
    }

    /// <summary>PUT /api/sensores/{id} — atualiza o sensor, inclusive a região (204).</summary>
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Atualizar(int id, [FromBody] SensorRequest req)
    {
        var sensor = await _db.Sensores.FindAsync(id);
        if (sensor is null)
        {
            return NotFound(new ErroResponse(404, $"Sensor {id} não encontrado"));
        }
        if (!await _db.Regioes.AnyAsync(r => r.Id == req.RegiaoId))
        {
            ModelState.AddModelError(nameof(req.RegiaoId), $"regiaoId {req.RegiaoId} não existe");
            return ValidationProblem(ModelState);
        }
        if (await _db.Sensores.AnyAsync(s => s.Codigo == req.Codigo && s.Id != id))
        {
            return Conflict(new ErroResponse(409, $"Já existe sensor com o código {req.Codigo}"));
        }

        sensor.Codigo = req.Codigo;
        sensor.Localizacao = req.Localizacao.Trim();
        sensor.NivelAlertaCm = req.NivelAlertaCm;
        sensor.NivelCriticoCm = req.NivelCriticoCm;
        sensor.UltimoNivelCm = req.UltimoNivelCm;
        sensor.Status = req.Status;
        sensor.RegiaoId = req.RegiaoId;
        await _db.SaveChangesAsync();

        return NoContent();
    }

    /// <summary>DELETE /api/sensores/{id} (204)</summary>
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Excluir(int id)
    {
        var sensor = await _db.Sensores.FindAsync(id);
        if (sensor is null)
        {
            return NotFound(new ErroResponse(404, $"Sensor {id} não encontrado"));
        }

        _db.Sensores.Remove(sensor);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
