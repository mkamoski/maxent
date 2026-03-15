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
            this.MinimumSize = new Size(1024, 768);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.Resize += MainForm_Resize;  // Handle resize events

            // Script dropdown
            Label scriptLabel = new Label { Text = "Select Script:", Location = new Point(10, 10), AutoSize = true };
            scriptDropdown = new ComboBox
            {
                Location = new Point(10, 30),
                Size = new Size((int)(this.ClientSize.Width * 0.9), 25),
                DropDownStyle = ComboBoxStyle.DropDownList,
                DropDownWidth = 800  // Allow dropdown to be wider than the control
            };
            scriptDropdown.SelectedIndexChanged += ScriptDropdown_SelectedIndexChanged;

            // Description box
            descriptionBox = new TextBox
            {
                Location = new Point(10, 60),
                Size = new Size((int)(this.ClientSize.Width * 0.9) - 10, 40),
                Multiline = true,
                ReadOnly = true,
                BackColor = SystemColors.Control
            };

            // Parameters panel (25% of height)
            Label paramLabel = new Label { Text = "Parameters:", Location = new Point(10, 105), AutoSize = true };
            int paramHeight = (int)(this.ClientSize.Height * 0.25);
            paramPanel = new Panel
            {
                Location = new Point(10, 125),
                Size = new Size((int)(this.ClientSize.Width * 0.9) - 10, paramHeight),
                BorderStyle = BorderStyle.FixedSingle,
                AutoScroll = true
            };

            // Buttons (positioned after param panel)
            int buttonY = 125 + paramHeight + 10;
            runButton = new Button
            {
                Text = "Run Script",
                Location = new Point(10, buttonY),
                Size = new Size(120, 30)
            };
            runButton.Click += RunButton_Click;

            viewImageButton = new Button
            {
                Text = "View Last Output Image",
                Location = new Point(140, buttonY),
                Size = new Size(180, 30),
                Enabled = false
            };
            viewImageButton.Click += ViewImageButton_Click;

            // Output box (25% of height, positioned after buttons)
            int outputY = buttonY + 40;
            Label outputLabel = new Label { Text = "Console Output:", Location = new Point(10, outputY), AutoSize = true };
            int outputHeight = (int)(this.ClientSize.Height * 0.25);
            outputBox = new RichTextBox
            {
                Location = new Point(10, outputY + 20),
                Size = new Size((int)(this.ClientSize.Width * 0.9) - 10, outputHeight),
                ReadOnly = true,
                Font = new Font("Consolas", 9),
                BackColor = Color.Black,
                ForeColor = Color.Lime
            };

            // Image preview (25% of height, positioned after output)
            int imageY = outputY + 20 + outputHeight + 10;
            Label imageLabel = new Label { Text = "Output Image:", Location = new Point(10, imageY), AutoSize = true };
            int imageHeight = (int)(this.ClientSize.Height * 0.25);
            imageBox = new PictureBox
            {
                Location = new Point(10, imageY + 20),
                Size = new Size((int)(this.ClientSize.Width * 0.9) - 10, imageHeight),
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

                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                foreach (var script in config.scripts)
                {
                    // Show full path in dropdown
                    string fullPath = Path.GetFullPath(Path.Combine(baseDir, script.file));
                    string displayText = $"{script.name} → {fullPath}";
                    scriptDropdown.Items.Add(displayText);
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
                        // Look for image in working directory first (where Python actually outputs it)
                        string imagePath = Path.GetFullPath(Path.Combine(maxentRoot, script.outputImage));

                        // Fallback: try relative to EXE location
                        if (!File.Exists(imagePath))
                        {
                            imagePath = Path.GetFullPath(Path.Combine(baseDir, script.outputImage));
                        }

                        if (File.Exists(imagePath))
                        {
                            LoadImage(imagePath);
                        }
                        else
                        {
                            AppendOutput($"\nImage not found: {imagePath}\n", Color.Yellow);
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

        private void MainForm_Resize(object? sender, EventArgs e)
        {
            // Calculate dynamic dimensions (90% width, 25% height for main controls)
            int width90 = (int)(this.ClientSize.Width * 0.9);
            int height25 = (int)(this.ClientSize.Height * 0.25);

            // Horizontal resizing (already working)
            if (scriptDropdown != null)
            {
                scriptDropdown.Size = new Size(width90, scriptDropdown.Height);
                scriptDropdown.DropDownWidth = Math.Max(width90, 800);
            }

            if (descriptionBox != null)
                descriptionBox.Size = new Size(width90 - 10, descriptionBox.Height);

            // Parameters panel - 25% height + horizontal resize
            if (paramPanel != null)
            {
                paramPanel.Size = new Size(width90 - 10, height25);
            }

            // Reposition buttons after param panel
            int buttonY = 125 + height25 + 10;
            if (runButton != null)
                runButton.Location = new Point(10, buttonY);
            if (viewImageButton != null)
                viewImageButton.Location = new Point(140, buttonY);

            // Reposition output label and box
            int outputY = buttonY + 40;
            foreach (Control ctrl in this.Controls)
            {
                if (ctrl is Label && ctrl.Text == "Console Output:")
                {
                    ctrl.Location = new Point(10, outputY);
                    break;
                }
            }

            // Output box - 25% height + horizontal resize
            if (outputBox != null)
            {
                outputBox.Location = new Point(10, outputY + 20);
                outputBox.Size = new Size(width90 - 10, height25);
            }

            // Reposition image label and box
            int imageY = outputY + 20 + height25 + 10;
            foreach (Control ctrl in this.Controls)
            {
                if (ctrl is Label && ctrl.Text == "Output Image:")
                {
                    ctrl.Location = new Point(10, imageY);
                    break;
                }
            }

            // Image box - 25% height + horizontal resize
            if (imageBox != null)
            {
                imageBox.Location = new Point(10, imageY + 20);
                imageBox.Size = new Size(width90 - 10, height25);
            }
        }
    }
}
