using System.Text.Json;

namespace MaxEntRunner
{
    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            ApplicationConfiguration.Initialize();
            Application.Run(new MainForm());
        }
    }

    public class ScriptConfig
    {
        public string pythonPath { get; set; } = "";
        public List<ScriptInfo> scripts { get; set; } = new();
    }

    public class ScriptInfo
    {
        public string name { get; set; } = "";
        public string file { get; set; } = "";
        public string description { get; set; } = "";
        public List<ParamInfo> parameters { get; set; } = new();
        public string? outputImage { get; set; }
    }

    public class ParamInfo
    {
        public string name { get; set; } = "";
        public string label { get; set; } = "";
        public string @default { get; set; } = "";
    }
}
