// Minimal indentation-based YAML reader for the flat/nested-map config
// shape used under .ai/ (mappings, block sequences, inline `[a, b]` lists,
// scalars). Not a general YAML parser — no anchors, multiline strings,
// flow mappings, or inline comments after a value. Good enough because
// devrig owns the shape of every file this reads.

function stripComments(text) {
  return text
    .split("\n")
    .filter((line) => line.trim() !== "" && !line.trim().startsWith("#"));
}

function indentOf(line) {
  return line.match(/^ */)[0].length;
}

function parseScalar(raw) {
  const s = raw.trim();
  if (s === "" || s === "null" || s === "~") return null;
  if (s === "true") return true;
  if (s === "false") return false;
  if (s.startsWith("[") && s.endsWith("]")) {
    const inner = s.slice(1, -1).trim();
    if (inner === "") return [];
    return inner.split(",").map((item) => parseScalar(item.trim()));
  }
  if (/^-?\d+(\.\d+)?$/.test(s)) return Number(s);
  if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith("'") && s.endsWith("'"))) {
    return s.slice(1, -1);
  }
  return s;
}

function splitKeyValue(content) {
  const idx = content.indexOf(":");
  if (idx === -1) return null;
  const key = content.slice(0, idx).trim();
  const rest = content.slice(idx + 1).trim();
  return [key, rest];
}

export function parseYamlLite(text) {
  const rawLines = stripComments(text);
  const lines = rawLines.map((line) => ({ indent: indentOf(line), content: line.trim() }));

  function parseBlock(pos, indent) {
    if (pos >= lines.length || lines[pos].indent !== indent) {
      return { value: null, pos };
    }
    const isSequence = lines[pos].content === "-" || lines[pos].content.startsWith("- ");
    if (isSequence) {
      const arr = [];
      while (pos < lines.length && lines[pos].indent === indent) {
        const { content } = lines[pos];
        if (content !== "-" && !content.startsWith("- ")) break;
        const itemContent = content === "-" ? "" : content.slice(2);
        if (itemContent === "") {
          const next = lines[pos + 1];
          if (next && next.indent > indent) {
            const child = parseBlock(pos + 1, next.indent);
            arr.push(child.value);
            pos = child.pos;
            continue;
          }
          arr.push(null);
          pos++;
          continue;
        }
        const kv = splitKeyValue(itemContent);
        if (kv && kv[1] === "" && lines[pos + 1] && lines[pos + 1].indent > indent) {
          // "- key:\n    nested..." — rare; not used by devrig's own config files.
          const child = parseBlock(pos + 1, lines[pos + 1].indent);
          arr.push({ [kv[0]]: child.value });
          pos = child.pos;
        } else {
          arr.push(parseScalar(itemContent));
          pos++;
        }
      }
      return { value: arr, pos };
    }

    const obj = {};
    while (pos < lines.length && lines[pos].indent === indent) {
      const kv = splitKeyValue(lines[pos].content);
      if (!kv) {
        pos++;
        continue;
      }
      const [key, rest] = kv;
      if (rest === "") {
        const next = lines[pos + 1];
        if (next && next.indent > indent) {
          const child = parseBlock(pos + 1, next.indent);
          obj[key] = child.value;
          pos = child.pos;
          continue;
        }
        obj[key] = null;
        pos++;
        continue;
      }
      obj[key] = parseScalar(rest);
      pos++;
    }
    return { value: obj, pos };
  }

  if (lines.length === 0) return {};
  return parseBlock(0, lines[0].indent).value;
}
