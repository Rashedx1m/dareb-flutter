# Dareb (Flutter)

Educational app built with Clean Architecture per feature. Conversations with the owner are in Arabic.

- Every feature, and every review of a feature, follows `docs/FEATURE_WORKFLOW.md`: file layout, naming, the step order (domain → data → cubit → DI/route/UI), dependency rules, and the done checklist. Review diffs against it and point to the rule that is broken.
- Checks: `flutter analyze` and `flutter test` must both be clean before any commit.
- Backend: Laravel API at `ApiConfig.baseUrl`; every request goes through `ApiClient`, and repositories wrap data source calls in `guard`.
