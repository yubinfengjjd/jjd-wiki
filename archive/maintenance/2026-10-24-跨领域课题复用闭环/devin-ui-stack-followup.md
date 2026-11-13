Resume SAME functional-tartan session. Consumer is idle/ended. Narrow missed-callsite fix only, no backend/skill changes or new features. Don't reread the whole plan.

Your last fix qualifies MethodOverview's detail-card StatusBadge, but the actual reported screenshot was the MethodsView LIST card. `frontend/src/components.tsx` line~227 still renders `.chain-ref-label` with `displayStatus(shown[0].meta)`, producing '需要适配 · 可用' under the doublet card. This is the original ambiguity and remains unfixed.

Use the same methodFigureStatusLabel helper for that actual method figure-stack/list-card label. Inspect its callers so shared gallery behavior stays unchanged. Add a test that renders the actual MethodCard/MethodsView image stack and proves an unverified method with a ready associated template shows '图模板可用' while its analysis remains unverified (no bare availability label that refers ambiguously to method). Keep the existing detail-card test.

Run affected frontend tests/build, report exact diff, then stop at review. No backend tests necessary; no formal/global writes/commits, original/trial project untouched. No algorithm suggestions to consumer. Codex will finish trial-tool fixture versioning and resume glimmer-opossum after this returns.
