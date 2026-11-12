using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AlagAlerta.Api.Migrations
{
    /// <inheritdoc />
    public partial class CriacaoInicial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TB_NET_REGIAO",
                columns: table => new
                {
                    ID_REGIAO = table.Column<int>(type: "NUMBER(10)", nullable: false)
                        .Annotation("Oracle:Identity", "START WITH 1 INCREMENT BY 1"),
                    NM_REGIAO = table.Column<string>(type: "NVARCHAR2(100)", maxLength: 100, nullable: false),
                    NM_CIDADE = table.Column<string>(type: "NVARCHAR2(100)", maxLength: 100, nullable: false),
                    SG_UF = table.Column<string>(type: "NVARCHAR2(2)", maxLength: 2, nullable: false),
                    QT_POPULACAO_RISCO = table.Column<int>(type: "NUMBER(10)", nullable: false),
                    DT_CRIACAO = table.Column<DateTime>(type: "TIMESTAMP(7)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TB_NET_REGIAO", x => x.ID_REGIAO);
                });

            migrationBuilder.CreateTable(
                name: "TB_NET_SENSOR",
                columns: table => new
                {
                    ID_SENSOR = table.Column<int>(type: "NUMBER(10)", nullable: false)
                        .Annotation("Oracle:Identity", "START WITH 1 INCREMENT BY 1"),
                    CD_SENSOR = table.Column<string>(type: "NVARCHAR2(30)", maxLength: 30, nullable: false),
                    DS_LOCALIZACAO = table.Column<string>(type: "NVARCHAR2(150)", maxLength: 150, nullable: false),
                    NR_NIVEL_ALERTA_CM = table.Column<int>(type: "NUMBER(10)", nullable: false),
                    NR_NIVEL_CRITICO_CM = table.Column<int>(type: "NUMBER(10)", nullable: false),
                    NR_ULTIMO_NIVEL_CM = table.Column<decimal>(type: "DECIMAL(7,2)", precision: 7, scale: 2, nullable: true),
                    ST_SENSOR = table.Column<string>(type: "NVARCHAR2(20)", maxLength: 20, nullable: false),
                    DT_INSTALACAO = table.Column<DateTime>(type: "TIMESTAMP(7)", nullable: false),
                    ID_REGIAO = table.Column<int>(type: "NUMBER(10)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TB_NET_SENSOR", x => x.ID_SENSOR);
                    table.ForeignKey(
                        name: "FK_NET_SENSOR_REGIAO",
                        column: x => x.ID_REGIAO,
                        principalTable: "TB_NET_REGIAO",
                        principalColumn: "ID_REGIAO",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "UK_NET_REGIAO_NOME_CIDADE",
                table: "TB_NET_REGIAO",
                columns: new[] { "NM_REGIAO", "NM_CIDADE" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TB_NET_SENSOR_ID_REGIAO",
                table: "TB_NET_SENSOR",
                column: "ID_REGIAO");

            migrationBuilder.CreateIndex(
                name: "UK_NET_SENSOR_CODIGO",
                table: "TB_NET_SENSOR",
                column: "CD_SENSOR",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TB_NET_SENSOR");

            migrationBuilder.DropTable(
                name: "TB_NET_REGIAO");
        }
    }
}
