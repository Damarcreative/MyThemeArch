#!/bin/bash

# Initialize Git Repository
# -------------------------

# Navigate to theme directory where script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$DIR" || exit

# Initialize git if not already done
if [ ! -d ".git" ]; then
    git init
    echo "Initialized git repository."
fi

# Create .gitignore
cat > .gitignore << EOL
# Backup directory
backup/

# Temporary files
*.tmp
temp.txt
EOL

# Add all files
git add .

# Create a professional initial commit
# If a commit already exists, we amend it to keep history clean as requested
if git rev-parse --verify HEAD >/dev/null 2>&1; then
    git commit --amend -m "feat: Initial release of Modified Archcraft Openbox Theme

- Customized Polybar with smart media controls (MPD/Playerctl auto-switch)
- Integrated Tint2 with toggleable visibility via settings configuration
- Enhanced window management and dynamic margins
- Added GUI for pin management
- Optimized for personal workflow based on Archcraft"
    echo "Updated initial commit with professional description."
else
    git commit -m "feat: Initial release of Modified Archcraft Openbox Theme

- Customized Polybar with smart media controls (MPD/Playerctl auto-switch)
- Integrated Tint2 with toggleable visibility via settings configuration
- Enhanced window management and dynamic margins
- Added GUI for pin management
- Optimized for personal workflow based on Archcraft"
    echo "Created initial commit."
fi

echo ""
echo "=========================================="
echo "    READY TO PUSH TO PRIVATE REPO"
echo "=========================================="
echo "Karena saya tidak memiliki akses password/token GitHub Anda,"
echo "Anda perlu menjalankan perintah push berikut secara manual:"
echo ""
echo "1. Buat repository baru di GitHub/GitLab (KOSONG, tanpa README)"
echo "2. Copy URL repository tersebut"
echo "3. Jalankan perintah dibawah ini:"
echo ""
echo "   git remote add origin <URL_REPOSITORY_ANDA>"
echo "   git branch -M main"
echo "   git push -u origin main"
echo "=========================================="
