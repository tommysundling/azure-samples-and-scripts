using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Extensions.Mcp;
using Microsoft.Extensions.Logging;
using System.ComponentModel;
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
        /// <param name="request">The MCP tool invocation request from the agent.</param>
        /// <returns>A JSON-formatted response containing the greeting message.</returns>
        [Function("HelloTool")]
        [Description("A simple tool that responds with a friendly 'Hello AI' greeting message.")]
        public McpToolResponse Run(
            [McpToolTrigger] McpToolRequest request)
        {
            _logger.LogInformation("HelloTool invoked by agent: {Agent}", request.McpContext.AgentName ?? "Unknown");

            // Create the response payload
            var responseData = new
            {
                message = "Hello AI",
                timestamp = DateTime.UtcNow.ToString("o"),
                toolName = "HelloTool",
                requestId = request.McpContext.RequestId
            };

            // Serialize to JSON
            var jsonResponse = JsonSerializer.Serialize(responseData, new JsonSerializerOptions
            {
                WriteIndented = true
            });

            _logger.LogInformation("Returning response: {Response}", jsonResponse);

            // Return the MCP tool response
            return new McpToolResponse
            {
                Content = jsonResponse,
                IsError = false
            };
        }
    }
}
