Read the actual callsite in `components.tsx`:Check `methodPlateFigures` return type and `ChainPlate`/`MethodCard` callers:`ChainPlate` is used only by `MethodCard` (the list card) — gallery `PlateCard` is separate and untouched. Applying the same helper:Line 90 is the method's own badge (`methodNoteLabel` → never bare '可用') — correct as-is. Now check how `MethodsView` feeds figures into `MethodCard` for the test:`methodFigures` reads `relations` from the method's page summary — build the exact list-card fixture. Add the test:All tests pass. Build + typecheck:Done. The missed callsite is fixed — exact diff:

**`frontend/src/components.tsx`** (the actual reported screenshot site)
- Line 4: added `methodFigureStatusLabel` to the `figureModels` import.
- Line 227 (`ChainPlate`, rendered by `MethodCard` in the MethodsView list): `displayStatus(shown[0].meta)` → `methodFigureStatusLabel(shown[0])`. The label now reads `需要适配 · 图模板可用` instead of `需要适配 · 可用`.

**`frontend/tests/methods.test.tsx`** (+20 lines)
- New test renders the real `MethodsView`/`MethodCard` figure stack: unverified method (`implementation_status: []`) + ready associated template via `adaptable` relation. Asserts `需要适配 · 图模板可用` appears, no `· 可用<` ambiguity, and `暂无已验证实现` preserved. Detail-card test kept.

**Preserved semantics**
- `displayStatus` still used at `components.tsx:90` for the card's *own* `StatusBadge` — methods render `笔记待确认/已确认` there (never '可用'), gallery template cards render their own '可用'. Gallery `PlateCard`, GraphView, and `displayStatus` itself unchanged.

**Verification**
- `npm run test`: all pass, including both badge tests.
- `tsc --noEmit` clean; `npm run build` ✓ 3.60s → new bundles `app/assets/index-DLauVPmm.js` (848.08 kB) and `GraphView-CA7_821I.js` (69.23 kB).

No backend/skill changes. Stopping at Codex review.