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
        private Button stopButton = null!;
        private Button viewImageButton = null!;
        private Button selectAllButton = null!;
        private Button copyButton = null!;
        private Button saveOutputButton = null!;
        private Button openOutputButton = null!;
        private Label timeoutLabel = null!;
        private ComboBox timeoutDropdown = null!;
        private Label documentationLabel = null!;
        private ComboBox documentationDropdown = null!;
        private RichTextBox outputBox = null!;
        private PictureBox imageBox = null!;
        private Process? currentProcess;
        private DateTime? runStartTime;
        private System.Windows.Forms.Timer runTimer = null!;

        public MainForm()
        {
            InitializeComponent();
            LoadConfig();
        }

        private void InitializeComponent()
        {
            // Form setup.
            this.Text = "MaxEnt Python Script Runner";
            this.Size = new Size(1024, 768);
            this.MinimumSize = new Size(1024, 768);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.WindowState = FormWindowState.Maximized;  // Maximize at startup
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
            documentationLabel = new Label { Text = "Documentation:", Location = new Point(10, 105), AutoSize = true };
            documentationDropdown = new ComboBox
            {
                Location = new Point(10, 125),
                Size = new Size((int)(this.ClientSize.Width * 0.9), 25),
                DropDownStyle = ComboBoxStyle.DropDownList
            };
            documentationDropdown.SelectedIndexChanged += DocumentationDropdown_SelectedIndexChanged;
            Label paramLabel = new Label { Text = "Parameters:", Location = new Point(10, 155), AutoSize = true };
            int paramHeight = (int)(this.ClientSize.Height * 0.25);
            paramPanel = new Panel
            {
                Location = new Point(10, 175),
                Size = new Size((int)(this.ClientSize.Width * 0.9) - 10, paramHeight),
                BorderStyle = BorderStyle.FixedSingle,
                AutoScroll = true
            };

            // Buttons (positioned after param panel)
            int buttonY = 175 + paramHeight + 10;
            runButton = new Button
            {
                Text = "Run Script",
                Location = new Point(10, buttonY),
                Size = new Size(120, 30)
            };
            runButton.Click += RunButton_Click;

            stopButton = new Button
            {
                Text = "Stop Script",
                Location = new Point(140, buttonY),
                Size = new Size(100, 30),
                Enabled = false
            };
            stopButton.Click += StopButton_Click;

            viewImageButton = new Button
            {
                Text = "View Last Output Image",
                Location = new Point(250, buttonY),
                Size = new Size(180, 30),
                Enabled = false
            };
            viewImageButton.Click += ViewImageButton_Click;

            selectAllButton = new Button
            {
                Text = "Select All Output",
                Location = new Point(440, buttonY),
                Size = new Size(100, 30)
            };
            selectAllButton.Click += SelectAllButton_Click;

            copyButton = new Button
            {
                Text = "Copy Selected Output",
                Location = new Point(550, buttonY),
                Size = new Size(100, 30)
            };
            copyButton.Click += CopyButton_Click;

            saveOutputButton = new Button
            {
                Text = "Save Output",
                Location = new Point(660, buttonY),
                Size = new Size(120, 30)
            };
            saveOutputButton.Click += SaveOutputButton_Click;

            openOutputButton = new Button
            {
                Text = "Open Output",
                Location = new Point(790, buttonY),
                Size = new Size(120, 30)
            };
            openOutputButton.Click += OpenOutputButton_Click;

            timeoutLabel = new Label
            {
                Text = "Stop if running > (minutes)",
                Location = new Point(790, buttonY + 6),
                AutoSize = true
            };

            timeoutDropdown = new ComboBox
            {
                Location = new Point(915, buttonY + 3),
                Size = new Size(80, 25),
                DropDownStyle = ComboBoxStyle.DropDownList
            };
            timeoutDropdown.Items.AddRange(new object[] { "15", "30", "45", "60", "75", "90", "105", "120" });
            timeoutDropdown.SelectedIndex = 1;

            runTimer = new System.Windows.Forms.Timer
            {
                Interval = 5000
            };
            runTimer.Tick += RunTimer_Tick;

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
            this.Controls.Add(documentationLabel);
            this.Controls.Add(documentationDropdown);
            this.Controls.Add(paramPanel);
            this.Controls.Add(runButton);
            this.Controls.Add(stopButton);
            this.Controls.Add(viewImageButton);
            this.Controls.Add(selectAllButton);
            this.Controls.Add(copyButton);
            this.Controls.Add(saveOutputButton);
            this.Controls.Add(openOutputButton);
            this.Controls.Add(timeoutLabel);
            this.Controls.Add(timeoutDropdown);
            this.Controls.Add(outputLabel);
            this.Controls.Add(outputBox);
            this.Controls.Add(imageLabel);
            this.Controls.Add(imageBox);
        }

        private string FindRepoRoot()
        {
            string dir = AppDomain.CurrentDomain.BaseDirectory.TrimEnd(Path.DirectorySeparatorChar);
            while (!string.IsNullOrEmpty(dir))
            {
                if (Directory.Exists(Path.Combine(dir, "venv_maxent")) ||
                    Directory.Exists(Path.Combine(dir, "python")) ||
                    File.Exists(Path.Combine(dir, "demo_simple_cartpole.py")))
                {
                    return dir;
                }
                string? parent = Path.GetDirectoryName(dir);
                if (parent == null || parent == dir) break;
                dir = parent;
            }
            return Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, ".."));
        }

        private string ResolvePath(string baseDir, string relativePath, string repoRoot)
        {
            string primary = Path.GetFullPath(Path.Combine(baseDir, relativePath));
            if (File.Exists(primary) || Directory.Exists(primary)) return primary;

            string stripped = relativePath;
            while (stripped.StartsWith(@"..\") || stripped.StartsWith("../"))
                stripped = stripped.Substring(3);
            string fallback = Path.GetFullPath(Path.Combine(repoRoot, stripped));
            return File.Exists(fallback) || Directory.Exists(fallback) ? fallback : primary;
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
                string repoRoot = FindRepoRoot();
                foreach (var script in config.scripts)
                {
                    string fullPath = ResolvePath(baseDir, script.file, repoRoot);
                    string displayText = $"{script.name} → {fullPath}";
                    scriptDropdown.Items.Add(displayText);
                }

                if (scriptDropdown.Items.Count > 0)
                    scriptDropdown.SelectedIndex = 0;

                LoadDocumentationList();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading config: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private sealed class DocItem
        {
            public string Name { get; }
            public string Path { get; }

            public DocItem(string name, string path)
            {
                Name = name;
                Path = path;
            }

            public override string ToString() => $"{Name} -- {Path}";
        }

        private void LoadDocumentationList()
        {
            documentationDropdown.Items.Clear();
            string repoRoot = FindRepoRoot();
            var files = Directory.GetFiles(repoRoot, "*.md", SearchOption.AllDirectories)
                .Where(path => !path.Contains("\\venv_maxent\\", StringComparison.OrdinalIgnoreCase)
                            && !path.Contains("\\python\\", StringComparison.OrdinalIgnoreCase)
                            && !path.Contains("\\.git\\", StringComparison.OrdinalIgnoreCase)
                            && !path.Contains("\\MaxEntRunner_", StringComparison.OrdinalIgnoreCase))
                .OrderBy(path => Path.GetFileName(path), StringComparer.OrdinalIgnoreCase)
                .ThenBy(path => path, StringComparer.OrdinalIgnoreCase);

            foreach (var file in files)
            {
                documentationDropdown.Items.Add(new DocItem(Path.GetFileName(file), file));
            }

            documentationDropdown.SelectedIndex = -1;
        }

        private void DocumentationDropdown_SelectedIndexChanged(object? sender, EventArgs e)
        {
            if (documentationDropdown.SelectedItem is not DocItem doc) return;

            AppendOutput($"\nDocumentation selected: {doc.Path}\n", Color.Cyan);

            try
            {
                Process.Start(new ProcessStartInfo("notepad++", $"\"{doc.Path}\"") { UseShellExecute = true });
            }
            catch
            {
                try
                {
                    Process.Start(new ProcessStartInfo("notepad", $"\"{doc.Path}\"") { UseShellExecute = true });
                }
                catch
                {
                    MessageBox.Show($"Failed to open documentation: {doc.Path}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
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
                stopButton.Enabled = true;
                outputBox.Clear();
                imageBox.Image = null;

                runStartTime = DateTime.Now;
                AppendOutput($"Start Time: {runStartTime:HH:mm:ss}\n", Color.Cyan);
                runTimer.Start();

                AppendOutput($"=== Starting: {script.name} ===\n", Color.Yellow);

                // Build command
                string baseDir = AppDomain.CurrentDomain.BaseDirectory;
                string repoRoot = FindRepoRoot();
                string pythonPath = ResolvePath(baseDir, config.pythonPath, repoRoot);
                string scriptPath = ResolvePath(baseDir, script.file, repoRoot);

                AppendOutput($"Script: {script.name}\n", Color.White);
                AppendOutput($"Path:   {scriptPath}\n", Color.White);

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

                // Set working directory to maxent root
                string maxentRoot = repoRoot;

                var startInfo = new ProcessStartInfo
                {
                    FileName = pythonPath,
                    Arguments = args.ToString(),
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true,
                    StandardOutputEncoding = Encoding.UTF8,
                    StandardErrorEncoding = Encoding.UTF8,
                    WorkingDirectory = maxentRoot  // Changed: use maxent root, not script dir
                };

                // Set HOME and add maxent root to PYTHONPATH
                startInfo.EnvironmentVariables["HOME"] = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
                startInfo.EnvironmentVariables["PYTHONPATH"] = maxentRoot;

                // Fix Unicode encoding for Windows console
                startInfo.EnvironmentVariables["PYTHONIOENCODING"] = "utf-8";
                // Silence CUDA/GPU warnings on machines without GPU drivers
                startInfo.EnvironmentVariables["CUDA_VISIBLE_DEVICES"] = "-1";
                startInfo.EnvironmentVariables["TF_CPP_MIN_LOG_LEVEL"] = "2";

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
                        // Resolve image path (handles ..\ prefix in config)
                        string imagePath = ResolvePath(baseDir, script.outputImage, repoRoot);

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

                if (runStartTime.HasValue)
                {
                    DateTime finishTime = DateTime.Now;
                    TimeSpan elapsed = finishTime - runStartTime.Value;
                    AppendOutput($"\nStart:  {runStartTime:HH:mm:ss}\n", Color.Cyan);
                    AppendOutput($"Finish: {finishTime:HH:mm:ss}\n", Color.Cyan);
                    AppendOutput($"Elapsed: {elapsed:hh\\:mm\\:ss}\n", Color.Cyan);
                }
            }
            catch (Exception ex)
            {
                AppendOutput($"\nEXCEPTION: {ex.Message}\n{ex.StackTrace}\n", Color.Red);
            }
            finally
            {
                runButton.Enabled = true;
                stopButton.Enabled = false;
                currentProcess = null;
                runTimer.Stop();
            }
        }

        private void StopButton_Click(object? sender, EventArgs e)
        {
            ForceStopCurrentProcess("User requested stop");
        }

        private void SelectAllButton_Click(object? sender, EventArgs e)
        {
            outputBox.SelectAll();
            outputBox.Focus();
        }

        private void CopyButton_Click(object? sender, EventArgs e)
        {
            string text = outputBox.SelectionLength > 0 ? outputBox.SelectedText : outputBox.Text;
            if (!string.IsNullOrEmpty(text))
            {
                Clipboard.SetDataObject(new DataObject(DataFormats.UnicodeText, text), true);
            }
        }

        private void SaveOutputButton_Click(object? sender, EventArgs e)
        {
            string filePath = SaveOutputToFile();
            AppendOutput($"\nOutput saved: {filePath}\n", Color.Cyan);
        }

        private void OpenOutputButton_Click(object? sender, EventArgs e)
        {
            string filePath = SaveOutputToFile();
            AppendOutput($"\nOutput saved: {filePath}\n", Color.Cyan);

            try
            {
                Process.Start(new ProcessStartInfo("notepad++", $"\"{filePath}\"") { UseShellExecute = true });
            }
            catch
            {
                try
                {
                    Process.Start(new ProcessStartInfo("notepad", $"\"{filePath}\"") { UseShellExecute = true });
                }
                catch
                {
                    AppendOutput("Failed to open the output file in an editor.\n", Color.Yellow);
                }
            }
        }

        private string SaveOutputToFile()
        {
            string timestamp = DateTime.Now.ToString("yyyy-MM-dd-HHmm-ss.fff");
            string fileName = $"maxent-output={timestamp}.txt";
            string filePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
            File.WriteAllText(filePath, outputBox.Text, Encoding.UTF8);
            return filePath;
        }

        private void RunTimer_Tick(object? sender, EventArgs e)
        {
            if (!runStartTime.HasValue || currentProcess == null || currentProcess.HasExited) return;

            int timeoutMinutes = GetTimeoutMinutes();
            if (timeoutMinutes <= 0) return;

            TimeSpan elapsed = DateTime.Now - runStartTime.Value;
            if (elapsed.TotalMinutes > timeoutMinutes)
            {
                ForceStopCurrentProcess($"Timeout after {timeoutMinutes} minutes");
            }
        }

        private int GetTimeoutMinutes()
        {
            if (timeoutDropdown.SelectedItem == null) return 0;
            if (!int.TryParse(timeoutDropdown.SelectedItem.ToString(), out int minutes)) return 0;
            return Math.Clamp(minutes, 15, 120);
        }

        private void ForceStopCurrentProcess(string reason)
        {
            if (currentProcess == null || currentProcess.HasExited) return;

            AppendOutput($"\n{reason}. Terminating process...\n", Color.Red);

            try
            {
                int pid = currentProcess.Id;
                currentProcess.Kill(true);
                try
                {
                    var killInfo = new ProcessStartInfo("taskkill", $"/PID {pid} /T /F")
                    {
                        UseShellExecute = false,
                        CreateNoWindow = true
                    };
                    Process.Start(killInfo)?.Dispose();
                }
                catch
                {
                    // Ignore taskkill errors
                }
            }
            catch (Exception ex)
            {
                AppendOutput($"Failed to terminate process: {ex.Message}\n", Color.Yellow);
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
                string repoRoot = FindRepoRoot();

                // Resolve image path (handles ..\ prefix in config)
                string imagePath = ResolvePath(baseDir, script.outputImage, repoRoot);

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
                AppendOutput($"Image loaded: {path}\n", Color.Cyan);
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

            if (documentationLabel != null)
                documentationLabel.Location = new Point(10, 105);
            if (documentationDropdown != null)
            {
                documentationDropdown.Location = new Point(10, 125);
                documentationDropdown.Size = new Size(width90, documentationDropdown.Height);
            }

            foreach (Control ctrl in this.Controls)
            {
                if (ctrl is Label && ctrl.Text == "Parameters:")
                {
                    ctrl.Location = new Point(10, 155);
                    break;
                }
            }

            // Reposition buttons after param panel
            int buttonY = 175 + height25 + 10;
            if (runButton != null)
                runButton.Location = new Point(10, buttonY);
            if (stopButton != null)
                stopButton.Location = new Point(140, buttonY);
            if (viewImageButton != null)
                viewImageButton.Location = new Point(250, buttonY);
            if (selectAllButton != null)
                selectAllButton.Location = new Point(440, buttonY);
            if (copyButton != null)
                copyButton.Location = new Point(550, buttonY);
            if (saveOutputButton != null)
                saveOutputButton.Location = new Point(660, buttonY);
            if (openOutputButton != null)
                openOutputButton.Location = new Point(790, buttonY);
            if (timeoutLabel != null)
                timeoutLabel.Location = new Point(920, buttonY + 6);
            if (timeoutDropdown != null)
                timeoutDropdown.Location = new Point(1045, buttonY + 3);

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
