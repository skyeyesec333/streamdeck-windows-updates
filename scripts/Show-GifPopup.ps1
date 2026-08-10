param(
    [Parameter(Mandatory)]
    [string]$GifPath,

    [int]$LoopCount = 3,

    [int]$FadeMilliseconds = 300
)

# A small, borderless lower-right popup. PictureBox supports animated GIFs,
# unlike the standard Windows toast image support.
if (-not (Test-Path -LiteralPath $GifPath)) {
    exit 0
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$references = @(
    [System.Windows.Forms.Form].Assembly.Location,
    [System.Drawing.Bitmap].Assembly.Location
)
Add-Type -TypeDefinition @'
using System;
using System.Drawing;
using System.Windows.Forms;

public sealed class StreamDeckGifPopupForm : Form
{
    // WS_EX_TOOLWINDOW prevents this short-lived notification from showing
    // in Alt+Tab or as a separate taskbar application.
    protected override CreateParams CreateParams
    {
        get
        {
            CreateParams parameters = base.CreateParams;
            parameters.ExStyle |= 0x00000080;
            return parameters;
        }
    }
}

public static class StreamDeckGifPopup
{
    public static void Show(string gifPath, int width, int height, int durationMilliseconds, int fadeMilliseconds)
    {
        Image image = Image.FromFile(gifPath);
        Form form = new StreamDeckGifPopupForm();
        form.FormBorderStyle = FormBorderStyle.None;
        form.StartPosition = FormStartPosition.Manual;
        form.Size = new Size(width, height);
        form.TopMost = true;
        form.ShowInTaskbar = false;
        form.BackColor = Color.Black;
        form.Opacity = 0.01;

        PictureBox picture = new PictureBox();
        picture.Dock = DockStyle.Fill;
        picture.BackColor = Color.Black;
        picture.SizeMode = PictureBoxSizeMode.Zoom;
        picture.Image = image;
        form.Controls.Add(picture);

        Timer timer = new Timer();
        timer.Interval = 15;
        int elapsed = 0;
        timer.Tick += delegate {
            elapsed += timer.Interval;
            if (elapsed < fadeMilliseconds)
                form.Opacity = Math.Max(0.01, (double)elapsed / fadeMilliseconds);
            else if (elapsed >= durationMilliseconds - fadeMilliseconds)
                form.Opacity = Math.Max(0.01, (double)(durationMilliseconds - elapsed) / fadeMilliseconds);
            else
                form.Opacity = 1;

            if (elapsed >= durationMilliseconds) {
                timer.Stop();
                form.Close();
            }
        };
        form.Shown += delegate {
            // Center on the left so the popup stays clear of the taskbar
            // and the Windows toast area.
            Rectangle workingArea = Screen.FromControl(form).WorkingArea;
            form.Location = new Point(workingArea.Left + 24, workingArea.Top + (workingArea.Height - form.Height) / 2);
            timer.Start();
        };
        Application.Run(form);
        timer.Dispose();
        image.Dispose();
        form.Dispose();
    }
}
'@ -ReferencedAssemblies $references

$image = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $GifPath).Path)
$maxWidth = 420
$maxHeight = 240
$scale = [Math]::Min(1, [Math]::Min($maxWidth / $image.Width, $maxHeight / $image.Height))
$popupWidth = [Math]::Round($image.Width * $scale)
$popupHeight = [Math]::Round($image.Height * $scale)

# GIF frame delays are stored in hundredths of a second. Use that to keep
# the popup open for a small, predictable number of complete loops.
try {
    $delays = $image.GetPropertyItem(0x5100).Value
    $loopMilliseconds = 0
    for ($offset = 0; $offset -lt $delays.Length; $offset += 4) {
        $loopMilliseconds += [System.BitConverter]::ToInt32($delays, $offset) * 10
    }
    if ($loopMilliseconds -le 0) { throw "No frame delay data" }
} catch {
    $loopMilliseconds = 2500
}
$displayMilliseconds = [Math]::Max(1500, $loopMilliseconds * [Math]::Max(1, $LoopCount))
$fadeMilliseconds = [Math]::Min([Math]::Max(1, $FadeMilliseconds), [Math]::Floor($displayMilliseconds / 2))
[StreamDeckGifPopup]::Show($GifPath, $popupWidth, $popupHeight, $displayMilliseconds, $fadeMilliseconds)
