using GDWeave.Godot;
using GDWeave.Godot.Variants;
using GDWeave.Modding;
using Godot;
using System.Collections.Generic;

namespace CustomPlayerPatch
{
    public class PlayerGravityPatch : IScriptMod
    {
        // Este módulo roda para o script player.gdc específico
        public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player.gdc";

        public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
        {
            // Vamos localizar onde a gravidade é definida e adaptar sua direção.
            var gravityWaiter = new MultiTokenWaiter(new[]
            {
                t => t is IdentifierToken { Name: "GRAVITY" }
            });

            foreach (var token in tokens)
            {
                if (gravityWaiter.Check(token))
                {
                    yield return new IdentifierToken("gravity_direction");
                    yield return token; // Preserva o resto dos tokens
                }
                else
                {
                    yield return token;
                }
            }
        }

        // Função para calcular a direção da gravidade
        private Vector3 CalculateGravity(Vector3 surfaceNormal)
        {
            return -surfaceNormal * 32.0f; // Mantém intensidade de gravidade original
        }

        // Função que aplica rotação e ajusta os controles
        public void UpdatePlayerOrientation(Node player, Vector3 surfaceNormal)
        {
            // Ajusta a rotação do jogador com base na normal da superfície
            var rotation = new Transform();
            rotation.basis.y = surfaceNormal.Normalized();
            rotation.basis.x = Vector3.Cross(Vector3.Up, rotation.basis.y).Normalized();
            rotation.basis.z = Vector3.Cross(rotation.basis.y, rotation.basis.x);

            player.GlobalTransform = rotation;

            // Aqui ajustaríamos os controles de acordo com a nova orientação.
        }
    }
}
