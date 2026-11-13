// ../../开发/frontend/src/api.ts
var isFigure = (meta) => meta.type === "layout" || meta.type === "template";

// ../../开发/frontend/src/figureModels.ts
function isWholeSource(meta) {
  return meta.type === "layout" && Object.keys(meta.panels).length !== 1;
}
function coversSource(template, source) {
  const letters = source.template_panels[template.id] ?? [];
  return template.layouts.includes(source.id) && source.templates.includes(template.id) && source.templates.length === 1 && Object.keys(source.template_panels).length === 1 && Object.keys(source.panels).length > 0 && letters.length === Object.keys(source.panels).length && template.chart_types.length === 1 && Object.keys(source.panels).every((p) => letters.includes(p) && source.panels[p] === template.chart_types[0]);
}
function figureGroups(figures) {
  const templates = figures.filter((p) => p.meta.type === "template");
  const grouped = new Map(templates.map((p) => [p.path, [p]]));
  const singles = [];
  for (const source of figures.filter((p) => p.meta.type === "layout")) {
    const match = templates.find((t) => t.meta.type === "template" && source.meta.type === "layout" && coversSource(t.meta, source.meta));
    if (match) grouped.get(match.path).push(source);
    else singles.push([source]);
  }
  return [...singles, ...grouped.values()];
}
var sourceLinks = (group) => group.filter((p) => p.meta.type === "layout").map((p) => ({ path: p.path, title: p.meta.title }));
function galleryEntries(pages) {
  const figures = pages.filter((p) => isFigure(p.meta) && p.meta.status !== "archived" && !isWholeSource(p.meta));
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
async function main() {
  const pages = await (await fetch("http://127.0.0.1:8765/api/pages")).json();
  const shelves = galleryEntries(pages);
  const method = methodDisplayFigures(pages.filter((p) => p.meta.type === "template" || p.meta.type === "layout").map((p) => ({ ...p, relation: "reference" })));
  const report = {
    single: shelves.single.map((p) => ({ path: p.path, sources: (p.sourceLinks || []).length })),
    templates: shelves.template.map((p) => ({ path: p.path, sources: (p.sourceLinks || []).length })),
    method_visuals: method.length
  };
  console.log(JSON.stringify(report, null, 2));
  if (shelves.single.length !== 5 || shelves.template.length !== 5) process.exit(1);
}
main();
