using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Extensions.Mcp;
using Microsoft.Extensions.Logging;
using System.Text.Json;

namespace McpHelloFunction
{
    /// <summary>
    /// MCP tool that responds with a simple "Hello AI" message.
    /// </summary>
    public class HelloTool
    {
        private readonly ILogger<HelloTool> _logger;

        public HelloTool(ILogger<HelloTool> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// A simple MCP tool that returns "Hello AI" formatted as JSON.
        /// </summary>
        /// <param name="context">The MCP tool invocation context from the agent.</param>
        /// <returns>A JSON-formatted response containing the greeting message.</returns>
        [Function(nameof(HelloTool))]
        public string Run(
            [McpToolTrigger(nameof(HelloTool), "Responds with a friendly 'Hello AI' greeting message formatted as JSON.")] ToolInvocationContext context
        )
        {
            _logger.LogInformation("C# MCP tool trigger function processed a request.");
            
            // Create the response payload
            var responseData = new
            {
                message = "Hello AI",
                timestamp = DateTime.UtcNow.ToString("o"),
                toolName = "HelloTool"
            };

            // Serialize to JSON
            var jsonResponse = JsonSerializer.Serialize(responseData, new JsonSerializerOptions
            {
                WriteIndented = true
            });

            _logger.LogInformation("Returning response: {Response}", jsonResponse);

            return jsonResponse;
        }
    }
}
