#!/bin/bash
[ "$DEBUG" == 'true' ] && set -x
[ "$STRICT" == 'true' ] && set -e

docs_base="website/containerforge/src/content/docs/containers"
tmp_docs_base="tmpwebsite/src/content/docs/containers"

safe_docs=(
  "CHANGELOG.md"
)

keep_docs_safe() {
  local app="$1"

  mkdir -p "$tmp_docs_base/${app}"
  echo "Keeping some docs safe..."
  for doc in "${safe_docs[@]}"; do
    if [ ! -f "$docs_base/${app}/${doc}" ]; then
      echo "Doc [$doc] does not exist, cannot keep it safe. Skipping."
      continue
    fi
    mv "$docs_base/${app}/${doc}" "$tmp_docs_base/${app}/${doc}"
  done
}

restore_safe_docs() {
  local app="$1"

  echo "Restoring safe docs..."
  for doc in "${safe_docs[@]}"; do
    if [ ! -f "$tmp_docs_base/${app}/${doc}" ]; then
      echo "Doc [$doc] does not exist, cannot restore it. Skipping."
      continue
    fi
    mv "$tmp_docs_base/${app}/${doc}" "$docs_base/${app}/${doc}"
  done
}

remove_old_docs() {
  local app="$1"

  echo "Removing old docs and recreating based on website repo..."
  rm -rf "$docs_base/${app}" || :
  mkdir -p "$docs_base/${app}" || echo "app path already exists, continuing..."
}

copy_new_docs() {
  local app="$1"

  echo "Copying new docs to website for ${app}"
  cp -rf "apps/${app}/docs/"* "$docs_base/${app}/" 2>/dev/null || :
  cp -rf "apps/${app}/icon.webp" "website/containerforge/public/img/hotlink-ok/container-icons/${app}.webp" 2>/dev/null || :
  cp -rf "apps/${app}/icon-small.webp" "website/containerforge/public/img/hotlink-ok/container-icons-small/${app}.webp" 2>/dev/null || :
  cp -rf "apps/${app}/screenshots/"* "website/containerforge/public/img/hotlink-ok/container-screenshots/${app}/" 2>/dev/null || :
  # Copy generated changelog to website docs
  if [ -f "apps/${app}/app-changelog.md" ]; then
    cp -f "apps/${app}/app-changelog.md" "$docs_base/${app}/CHANGELOG.md"
  fi
}

check_and_fix_title() {
  local file="$1"

  echo "Checking title..."

  ok_title="false"
  echo "Getting the first line"
  if grep -q "^---$" "${file}"; then
    ok_title="true"
  elif grep -q "^# " "${file}"; then
    echo "Found old-style title, fixing..."
    title=$(grep "^# " "${file}" | cut -d " " -f 2-)
    # Remove title
    sed -i "s/^# ${title}//" "${file}"
    content=$(cat "${file}")
    echo -e "---\ntitle: ${title}\n---\n${content}" >"${file}"
    ok_title="true"
  else
    ok_title="false"
  fi

  if [ ${ok_title} == "false" ]; then
    echo "Doc title should use front matter and not # for title, for example"
    echo "---"
    echo "title: some title"
    echo "---"
    return 1
  fi

  echo "Title is ok"

  return 0
}

process_index() {
  local app="$1"

  local index_path="$docs_base/${app}/index.md"
  local bake_path="apps/${app}/docker-bake.hcl"
  local template_path="templates/README.md.tmpl"

  echo "Getting data from docker-bake.hcl..."
  version=$(grep -A1 'variable "VERSION"' "${bake_path}" | grep 'default' | sed 's/.*"\(.*\)".*/\1/')
  license=$(grep -A1 'variable "LICENSE"' "${bake_path}" | grep 'default' | sed 's/.*"\(.*\)".*/\1/')
  source=$(grep -A1 'variable "SOURCE"' "${bake_path}" | grep 'default' | sed 's/.*"\(.*\)".*/\1/')

  # Build docs links
  docs_links=""
  echo "Iterating over all files in the docs directory..."
  for f in "$docs_base/${app}/"*.md*; do
    # If glob didn't match, skip
    [ -e "${f}" ] || continue

    echo "Checking file: ${f}"
    filename=$(basename "${f}")

    # If title is not ok, skip
    if ! check_and_fix_title "${f}"; then
      echo "Title is not ok, skipping..."
      continue
    fi

    # If file is index.md, skip
    if [ "${filename}" == "index.md" ]; then
      echo "File is index.md, not adding it to the links"
      continue
    fi

    title=$(grep -A1 "^---" "${f}" | grep "title:" | head -n 1 | sed 's/.*title: *//')
    echo "The title is: ${title}"

    filename="${filename##*/}"
    filenameURL=${filename%.*}
    filenameURL=${filenameURL,,}
    link="- [**${title}**](./${filenameURL})"
    echo "The link is: ${link}"
    docs_links="${docs_links}${link}\n"
  done

  # Build README content
  readme_content=""
  if [ -f "apps/${app}/README.md" ]; then
    echo "Appending README.md content..."
    readme_content="## Readme\n\n"
    tmp_readme=$(tail -n +4 "apps/${app}/README.md" | sed 's/##/###/')
    readme_content="${readme_content}${tmp_readme}"
  fi

  echo "Creating index.md from template..."
  # Escape license dashes for badge URLs
  license_badge="${license//\-/--}"

  cp "${template_path}" "${index_path}"
  sed -i "s|{{ APP }}|${app}|g" "${index_path}"
  sed -i "s|{{ VERSION }}|${version}|g" "${index_path}"
  sed -i "s|{{ LICENSE }}|${license_badge}|g" "${index_path}"
  sed -i "s|{{ SOURCE }}|${source}|g" "${index_path}"

  # Replace multiline placeholders
  # Use a temp file approach for docs links and readme content
  local tmpfile
  tmpfile=$(mktemp)
  while IFS= read -r line; do
    if [[ "$line" == *"{{ DOCS_LINKS }}"* ]]; then
      echo -e "${docs_links}" >>"${tmpfile}"
    elif [[ "$line" == *"{{ README_CONTENT }}"* ]]; then
      echo -e "${readme_content}" >>"${tmpfile}"
    else
      echo "$line" >>"${tmpfile}"
    fi
  done < "${index_path}"
  mv "${tmpfile}" "${index_path}"
}

main() {
  local app="$1"

  if [ ! -f "apps/${app}/docker-bake.hcl" ]; then
    echo "docker-bake.hcl does not exist for ${app}, skipping..."
    return 0
  fi

  echo "Copying docs to website for ${app}"

  keep_docs_safe "$app"
  remove_old_docs "$app"
  copy_new_docs "$app"
  process_index "$app"
  restore_safe_docs "$app"

  echo "Finished processing ${app}"
}

main "$1"
