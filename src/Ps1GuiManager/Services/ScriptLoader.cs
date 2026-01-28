using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using Ps1GuiManager.Models;

namespace Ps1GuiManager.Services;

public class ScriptLoader
{
    private readonly Assembly _assembly;

    public ScriptLoader()
    {
        _assembly = Assembly.GetExecutingAssembly();
    }

    public List<Script> LoadScripts()
    {
        var scripts = new List<Script>();
        var resourceNames = _assembly.GetManifestResourceNames()
            .Where(name => name.EndsWith(".ps1", StringComparison.OrdinalIgnoreCase))
            .ToList();

        foreach (var resourceName in resourceNames)
        {
            try
            {
                using var stream = _assembly.GetManifestResourceStream(resourceName);
                if (stream == null) continue;

                using var reader = new StreamReader(stream, Encoding.UTF8);
                var content = reader.ReadToEnd();
                var fileName = ExtractFileName(resourceName);
                var description = ExtractDescription(content);

                scripts.Add(new Script
                {
                    Name = Path.GetFileNameWithoutExtension(fileName),
                    Path = resourceName,
                    Content = content,
                    Description = description
                });
            }
            catch (Exception ex)
            {
                // Log error but continue loading other scripts
                System.Diagnostics.Debug.WriteLine($"Failed to load script {resourceName}: {ex.Message}");
            }
        }

        return scripts;
    }

    private string ExtractFileName(string resourceName)
    {
        // Extract filename from resource name (e.g., "Ps1GuiManager.Scripts.install-winget.ps1")
        var parts = resourceName.Split('.');
        if (parts.Length >= 2)
        {
            return parts[^2] + "." + parts[^1];
        }
        return resourceName;
    }

    private string ExtractDescription(string content)
    {
        var lines = content.Split('\n');
        foreach (var line in lines.Take(20)) // Check first 20 lines
        {
            var trimmed = line.Trim();
            if (trimmed.StartsWith("#") && 
                !trimmed.StartsWith("# Copyright", StringComparison.OrdinalIgnoreCase) &&
                !trimmed.StartsWith("# Usage:", StringComparison.OrdinalIgnoreCase) &&
                !trimmed.StartsWith("# Remote exec:", StringComparison.OrdinalIgnoreCase) &&
                !trimmed.StartsWith("# Error handling", StringComparison.OrdinalIgnoreCase))
            {
                var desc = trimmed.Substring(1).Trim();
                if (!string.IsNullOrWhiteSpace(desc) && desc.Length > 5)
                {
                    return desc;
                }
            }
        }
        return string.Empty;
    }
}
