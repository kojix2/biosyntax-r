#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>
#include <R_ext/Visibility.h>

extern SEXP C_biosyntax_version(void);
extern SEXP C_biosyntax_normalize_format(SEXP);
extern SEXP C_biosyntax_render_ansi(SEXP, SEXP);
extern SEXP C_biosyntax_spans(SEXP, SEXP);
extern SEXP C_biosyntax_formats(void);
extern SEXP C_biosyntax_classes(void);

static const R_CallMethodDef CallEntries[] = {
    {"biosyntax_version", (DL_FUNC) &C_biosyntax_version, 0},
    {"biosyntax_normalize_format", (DL_FUNC) &C_biosyntax_normalize_format, 1},
    {"biosyntax_render_ansi", (DL_FUNC) &C_biosyntax_render_ansi, 2},
    {"biosyntax_spans", (DL_FUNC) &C_biosyntax_spans, 2},
    {"biosyntax_formats", (DL_FUNC) &C_biosyntax_formats, 0},
    {"biosyntax_classes", (DL_FUNC) &C_biosyntax_classes, 0},
    {NULL, NULL, 0}
};

void attribute_visible R_init_biosyntax(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
