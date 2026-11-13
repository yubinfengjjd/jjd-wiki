var __create = Object.create;
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __getProtoOf = Object.getPrototypeOf;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toESM = (mod, isNodeMode, target) => (target = mod != null ? __create(__getProtoOf(mod)) : {}, __copyProps(
  // If the importer is in node compatibility mode or this is not an ESM
  // file that has been converted to a CommonJS file using a Babel-
  // compatible transform (i.e. "__esModule" has not been set), then set
  // "default" to the CommonJS "module.exports" for node compatibility.
  isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target,
  mod
));

// <stdin>
var import_strict = __toESM(require("node:assert/strict"));

// ../../开发/frontend/src/api.ts
var isFigure = (meta) => meta.type === "layout" || meta.type === "template";

// ../../开发/frontend/src/figureModels.ts
function isWholeSource(meta) {
  return meta.type === "layout" && Object.keys(meta.panels).length !== 1;
}
function coversSource(template2, source2) {
  const letters = source2.template_panels[template2.id] ?? [];
  return template2.layouts.includes(source2.id) && source2.templates.includes(template2.id) && source2.templates.length === 1 && Object.keys(source2.template_panels).length === 1 && Object.keys(source2.panels).length > 0 && letters.length === Object.keys(source2.panels).length && template2.chart_types.length === 1 && Object.keys(source2.panels).every((p) => letters.includes(p) && source2.panels[p] === template2.chart_types[0]);
}
function figureGroups(figures) {
  const templates = figures.filter((p) => p.meta.type === "template");
  const grouped = new Map(templates.map((p) => [p.path, [p]]));
  const singles = [];
  for (const source2 of figures.filter((p) => p.meta.type === "layout")) {
    const match = templates.find((t) => t.meta.type === "template" && source2.meta.type === "layout" && coversSource(t.meta, source2.meta));
    if (match) grouped.get(match.path).push(source2);
    else singles.push([source2]);
  }
  return [...singles, ...grouped.values()];
}
var sourceLinks = (group) => group.filter((p) => p.meta.type === "layout").map((p) => ({ path: p.path, title: p.meta.title }));
function galleryEntries(pages2) {
  const figures = pages2.filter((p) => isFigure(p.meta) && p.meta.status !== "archived" && !isWholeSource(p.meta));
  const sources = figures.filter((p) => p.meta.type === "layout");
  const templates = figures.filter((p) => p.meta.type === "template");
  const representatives = figureGroups(figures).map((group) => ({
    ...group.find((p) => p.meta.type === "layout") ?? group[0],
    sourceLinks: sourceLinks(group)
  }));
  const order = new Map(figures.map((p, i) => [p.path, i]));
  return {
    single: representatives.sort((a, b) => order.get(a.path) - order.get(b.path)),
    template: templates.map((p) => ({ ...p, sourceLinks: sources.filter((s) => coversSource(p.meta, s.meta)).map((s) => ({ path: s.path, title: s.meta.title })) }))
  };
}
function methodDisplayFigures(figures) {
  return figureGroups(figures).map((group) => ({
    ...group.find((p) => p.meta.type === "template") ?? group[0],
    sourceLinks: sourceLinks(group)
  }));
}

// <stdin>
var tid = "shared-bar";
var source = (id) => ({ path: "layouts/" + id + ".md", meta: {
  type: "layout",
  id,
  title: id,
  status: "pending_template",
  language: "python",
  tags: [],
  favorite: false,
  panels: { A: "bar" },
  chart_types: ["bar"],
  templates: [tid],
  template_panels: { [tid]: ["A"] }
} });
var template = { path: "templates/" + tid + ".md", meta: {
  type: "template",
  id: tid,
  title: "One shared style",
  status: "ready",
  language: "python",
  tags: [],
  favorite: false,
  panels: ["A"],
  chart_types: ["bar"],
  layouts: ["source-one", "source-two"]
} };
var pages = [source("source-one"), source("source-two"), template];
var shelves = galleryEntries(pages);
var method = methodDisplayFigures(pages.map((p) => ({ ...p, relation: "reference" })));
import_strict.default.equal(shelves.single.length, 1);
import_strict.default.equal(shelves.template.length, 1);
import_strict.default.equal(method.length, 1);
import_strict.default.equal(shelves.single[0].sourceLinks.length, 2);
import_strict.default.equal(method[0].sourceLinks.length, 2);
console.log(JSON.stringify({
  passed: true,
  description: "Two source pages explicitly reuse the same template and exact panel structure; Gallery and method display both show one style and preserve both source links.",
  gallery_style_paths: shelves.single.map((p) => p.path),
  callable_templates: shelves.template.length,
  method_visuals: method.length
}, null, 2));
