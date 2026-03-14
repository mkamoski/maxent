using System.Diagnostics;
using System.Text;
using System.Text.Json;

namespace MaxEntRunner
{
    public partial class MainForm : Form
    {
        private ScriptConfig? config;
        private ComboBox scriptDropdown = null!;
        private TextBox descriptionBox = null!;
        private Panel paramPanel = null!;
        private Dictionary<string, TextBox> paramTextBoxes = new();
        private Button runButton = null!;
        private Button viewImageButton = null!;
        private RichTextBox outputBox = null!;
        private PictureBox imageBox = null!;
        private Process? currentProcess;

        public MainForm()
        {
            InitializeComponent();
            LoadConfig();
        }

        private void InitializeComponent()
        {
            // Form setup
            this.Text = "MaxEnt Python Script Runner";
            this.Size = new Size(1024, 768);
            this.MinimumSize = new Size(800, 600);
            this.StartPosition = FormStartPosition.CenterScreen;

            // Script dropdown
            Label scriptLabel = new Label { Text = "Select Script:", Location = new Point(10, 10), AutoSize = true };
            scriptDropdown = new ComboBox
            {
                Location = new Point(10, 30),
                Size = new Size(980, 25),
                DropDownStyle = ComboBoxStyle.DropDownList
            };
            scriptDropdown.SelectedIndexChanged += ScriptDropdown_SelectedIndexChanged;

            // Description box
            descriptionBox = new TextBox
            {
                Location = new Point(10, 60),
                Size = new Size(980, 40),
                Multiline = true,
                ReadOnly = true,
                BackColor = SystemColors.Control
            };

            // Parameters panel
            Label paramLabel = new Label { Text = "Parameters:", Location = new Point(10, 105), AutoSize = true };
            paramPanel = new Panel
            {
                Location = new Point(10, 125),
                Size = new Size(980, 120),
                BorderStyle = BorderStyle.FixedSingle,
                AutoScroll = true
            };

            // Buttons
            runButton = new Button
            {
                Text = "Run Script",
                Location = new Point(10, 250),
                Size = new Size(120, 30)
            };
            runButton.Click += RunButton_Click;

            viewImageButton = new Button
            {
                Text = "View Last Output Image",
                Location = new Point(140, 250),
                Size = new Size(180, 30),
                Enabled = false
            };
            viewImageButton.Click += ViewImageButton_Click;

            // Output box
            Label outputLabel = new Label { Text = "Console Output:", Location = new Point(10, 285), AutoSize = true };
            outputBox = new RichTextBox
            {
                Location = new Point(10, 305),
                Size = new Size(980, 150),
                ReadOnly = true,
                Font = new Font("Consolas", 9),
                BackColor = Color.Black,
                ForeColor = Color.Lime
            };

            // Image preview
            Label imageLabel = new Label { Text = "Output Image:", Location = new Point(10, 460), AutoSize = true };
            imageBox = new PictureBox
            {
                Location = new Point(10, 480),
                Size = new Size(980, 250),
                BorderStyle = BorderStyle.FixedSingle,
                SizeMode = PictureBoxSizeMode.Zoom
            };

            // Add controls
            this.Controls.Add(scriptLabel);
            this.Controls.Add(scriptDropdown);
            this.Controls.Add(descriptionBox);
            this.Controls.Add(paramLabel);
            this.Controls.Add(paramPanel);
            this.Controls.Add(runButton);
            this.Controls.Add(viewImageButton);
            this.Controls.Add(outputLabel);
            this.Controls.Add(outputBox);
            this.Controls.Add(imageLabel);
            this.Controls.Add(imageBox);
        }

        private void LoadConfig()
        {
            try
            {
                string configPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "ScriptConfig.json");
                string json = File.ReadAllText(configPath);
                config = JsonSerializer.Deserialize<ScriptConfig>(json);

                if (config == null || config.scripts.Count == 0)
                {
                    MessageBox.Show("No scripts found in ScriptConfig.json", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }

                foreach (var script in config.scripts)
                {
                    scriptDropdown.Items.Add(script.name);
                }

                if (scriptDropdown.Items.Count > 0)
                    scriptDropdown.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading config: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void ScriptDropdown_SelectedIndexChanged(object? sender, EventArgs e)
        {
            if (config == null || scriptDropdown.SelectedIndex < 0) return;

            var script = config.scripts[scriptDropdown.SelectedIndex];
            descriptionBox.Text = script.description;

            // Clear and rebuild parameter controls
            paramPanel.Controls.Clear();
            paramTextBoxes.Clear();

            int y = 10;
            foreach (var param in script.parameters)
            {
                Label label = new Label
                {
                    Text = param.label + ":",
                    Location = new Point(10, y),
                    AutoSize = true
                };

                TextBox textBox = new TextBox
                {
                    Location = new Point(150, y - 3),
                    Size = new Size(300, 25),
                    Text = param.@default
                };

                paramTextBoxes[param.name] = textBox;

                paramPanel.Controls.Add(label);
                paramPanel.Controls.Add(textBox);

                y += 30;
            }

            // Enable view button if script has output image
            viewImageButton.Enabled = !string.IsNullOrEmpty(script.outputImage);
        }

        private async void RunButton_Click(object? sender, EventArgs e)
        {
            if (config == null || scriptDropdown.SelectedIndex < 0) return;

            var script = config.scripts[scriptDropdown.SelectedIndex];

            try
            {
                runButton.Enabled = false;
                outputBox.Clear();
                imageBox.Image = null;

                AppendOutput($"=== Starting: {script.name} ===\n", Color.Yellow);

                // Build command
                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                string pythonPath = Path.GetFullPath(Path.Combine(baseDir, config.pythonPath));
                string scriptPath = Path.GetFullPath(Path.Combine(baseDir, script.file));

                if (!File.Exists(pythonPath))
                {
                    AppendOutput($"ERROR: Python not found at: {pythonPath}\n", Color.Red);
                    return;
                }

                if (!File.Exists(scriptPath))
                {
                    AppendOutput($"ERROR: Script not found at: {scriptPath}\n", Color.Red);
                    return;
                }

                // Build arguments
                StringBuilder args = new StringBuilder($"\"{scriptPath}\"");
                foreach (var param in script.parameters)
                {
                    if (paramTextBoxes.TryGetValue(param.name, out var textBox))
                    {
                        string value = textBox.Text.Trim();
                        if (!string.IsNullOrEmpty(value))
                        {
                            args.Append($" --{param.name}=\"{value}\"");
                        }
                    }
                }

                // Set working directory to maxent root (parent of gui_runner_published)
                string maxentRoot = Path.GetFullPath(Path.Combine(baseDir, ".."));

                var startInfo = new ProcessStartInfo
                {
                    FileName = pythonPath,
                    Arguments = args.ToString(),
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true,
                    WorkingDirectory = maxentRoot  // Changed: use maxent root, not script dir
                };

                // Set HOME and add maxent root to PYTHONPATH
                startInfo.EnvironmentVariables["HOME"] = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
                startInfo.EnvironmentVariables["PYTHONPATH"] = maxentRoot;

                // Fix Unicode encoding for Windows console
                startInfo.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";

                AppendOutput($"Command: {pythonPath} {args}\n", Color.Cyan);
                AppendOutput($"Working Dir: {startInfo.WorkingDirectory}\n\n", Color.Cyan);

                currentProcess = new Process { StartInfo = startInfo };

                currentProcess.OutputDataReceived += (s, e) =>
                {
                    if (e.Data != null)
                    {
                        this.Invoke(() => AppendOutput(e.Data + "\n", Color.Lime));
                    }
                };

                currentProcess.ErrorDataReceived += (s, e) =>
                {
                    if (e.Data != null)
                    {
                        this.Invoke(() => AppendOutput(e.Data + "\n", Color.Yellow));
                    }
                };

                currentProcess.Start();
                currentProcess.BeginOutputReadLine();
                currentProcess.BeginErrorReadLine();

                await Task.Run(() => currentProcess.WaitForExit());

                int exitCode = currentProcess.ExitCode;
                if (exitCode == 0)
                {
                    AppendOutput($"\n=== SUCCESS (Exit Code: {exitCode}) ===\n", Color.Green);

                    // Try to load output image
                    if (!string.IsNullOrEmpty(script.outputImage))
                    {
                        string imagePath = Path.GetFullPath(Path.Combine(baseDir, script.outputImage));
                        if (File.Exists(imagePath))
                        {
                            LoadImage(imagePath);
                        }
                    }
                }
                else
                {
                    AppendOutput($"\n=== FAILED (Exit Code: {exitCode}) ===\n", Color.Red);
                }
            }
            catch (Exception ex)
            {
                AppendOutput($"\nEXCEPTION: {ex.Message}\n{ex.StackTrace}\n", Color.Red);
            }
            finally
            {
                runButton.Enabled = true;
                currentProcess = null;
            }
        }

        private void ViewImageButton_Click(object? sender, EventArgs e)
        {
            if (config == null || scriptDropdown.SelectedIndex < 0) return;

            var script = config.scripts[scriptDropdown.SelectedIndex];
            if (string.IsNullOrEmpty(script.outputImage)) return;

            try
            {
                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                string imagePath = Path.GetFullPath(Path.Combine(baseDir, script.outputImage));

                if (File.Exists(imagePath))
                {
                    LoadImage(imagePath);
                    Process.Start(new ProcessStartInfo(imagePath) { UseShellExecute = true });
                }
                else
                {
                    MessageBox.Show($"Image not found: {imagePath}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error opening image: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void LoadImage(string path)
        {
            try
            {
                // Load a copy to avoid file lock
                using (var fs = new FileStream(path, FileMode.Open, FileAccess.Read))
                {
                    imageBox.Image?.Dispose();
                    imageBox.Image = Image.FromStream(fs);
                }
                AppendOutput($"Image loaded: {Path.GetFileName(path)}\n", Color.Cyan);
            }
            catch (Exception ex)
            {
                AppendOutput($"Error loading image: {ex.Message}\n", Color.Red);
            }
        }

        private void AppendOutput(string text, Color color)
        {
            if (outputBox.InvokeRequired)
            {
                outputBox.Invoke(() => AppendOutput(text, color));
                return;
            }

            outputBox.SelectionStart = outputBox.TextLength;
            outputBox.SelectionLength = 0;
            outputBox.SelectionColor = color;
            outputBox.AppendText(text);
            outputBox.SelectionColor = outputBox.ForeColor;
            outputBox.ScrollToCaret();
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            if (currentProcess != null && !currentProcess.HasExited)
            {
                var result = MessageBox.Show("Script is still running. Force close?", "Confirm", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
                if (result == DialogResult.Yes)
                {
                    currentProcess.Kill();
                }
                else
                {
                    e.Cancel = true;
                    return;
                }
            }

            imageBox.Image?.Dispose();
            base.OnFormClosing(e);
        }
    }
}
