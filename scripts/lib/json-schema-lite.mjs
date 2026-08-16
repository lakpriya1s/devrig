// Minimal JSON Schema validator covering the subset used by .ai/schemas/*:
// type, required, properties, additionalProperties, items, minItems,
// minProperties, minLength, enum, and local $ref/$defs. Not general-purpose —
// enough to validate devrig's own config files without adding a dependency.

function resolveRef(ref, root) {
  const parts = ref.replace(/^#\//, "").split("/");
  return parts.reduce((node, part) => node?.[part], root);
}

function typeOf(value) {
  if (Array.isArray(value)) return "array";
  if (value === null) return "null";
  return typeof value;
}

export function validate(schema, data, root = schema, path = "$") {
  const errors = [];
  if (schema.$ref) {
    const resolved = resolveRef(schema.$ref, root);
    if (!resolved) {
      errors.push(`${path}: unresolved $ref "${schema.$ref}"`);
      return errors;
    }
    return validate(resolved, data, root, path);
  }

  if (schema.type && typeOf(data) !== schema.type) {
    errors.push(`${path}: expected type "${schema.type}", got "${typeOf(data)}"`);
    return errors;
  }

  if (schema.enum && !schema.enum.includes(data)) {
    errors.push(`${path}: value "${data}" not in enum [${schema.enum.join(", ")}]`);
  }

  if (schema.type === "object" || (typeOf(data) === "object" && schema.properties)) {
    for (const key of schema.required ?? []) {
      if (!(key in data)) errors.push(`${path}: missing required property "${key}"`);
    }
    if (schema.minProperties && Object.keys(data).length < schema.minProperties) {
      errors.push(`${path}: expected at least ${schema.minProperties} properties`);
    }
    for (const [key, value] of Object.entries(data)) {
      if (schema.properties?.[key]) {
        errors.push(...validate(schema.properties[key], value, root, `${path}.${key}`));
      } else if (schema.additionalProperties === false) {
        errors.push(`${path}.${key}: unexpected property (additionalProperties: false)`);
      } else if (schema.additionalProperties && typeof schema.additionalProperties === "object") {
        errors.push(...validate(schema.additionalProperties, value, root, `${path}.${key}`));
      }
    }
  }

  if (schema.type === "array") {
    if (schema.minItems && data.length < schema.minItems) {
      errors.push(`${path}: expected at least ${schema.minItems} items, got ${data.length}`);
    }
    if (schema.items) {
      data.forEach((item, i) => errors.push(...validate(schema.items, item, root, `${path}[${i}]`)));
    }
  }

  if (schema.type === "string" && schema.minLength && data.length < schema.minLength) {
    errors.push(`${path}: string shorter than minLength ${schema.minLength}`);
  }

  return errors;
}
