find . -type f -name "*.sh" | while IFS= read -r file; do
    chmod +x $file
done
