#include <R.h>
#include <Rinternals.h>

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "biosyntax.h"

static biosyn_format_t parse_format(SEXP format) {
    const char *name;
    biosyn_format_t value;

    if (TYPEOF(format) != STRSXP || XLENGTH(format) != 1 ||
        STRING_ELT(format, 0) == NA_STRING) {
        Rf_error("`format` must be one non-missing character string");
    }
    name = Rf_translateCharUTF8(STRING_ELT(format, 0));
    value = biosyn_format_from_name(name);
    if (value == BIOSYN_FORMAT_UNKNOWN) {
        Rf_error("unsupported BioSyntax format: %s", name);
    }
    return value;
}

static void check_lines(SEXP lines) {
    R_xlen_t i;
    if (TYPEOF(lines) != STRSXP) {
        Rf_error("`lines` must be a character vector");
    }
    for (i = 0; i < XLENGTH(lines); i++) {
        if (STRING_ELT(lines, i) == NA_STRING) {
            Rf_error("`lines` must not contain NA");
        }
    }
}

SEXP C_biosyntax_version(void) {
    return Rf_mkString(biosyn_version());
}

SEXP C_biosyntax_normalize_format(SEXP format) {
    biosyn_format_t value = parse_format(format);
    return Rf_mkString(biosyn_format_name(value));
}

SEXP C_biosyntax_render_ansi(SEXP lines, SEXP format) {
    R_xlen_t i, nlines;
    biosyn_state_t state;
    biosyn_format_t fmt;
    SEXP out;

    check_lines(lines);
    fmt = parse_format(format);
    nlines = XLENGTH(lines);
    biosyn_state_init(&state, fmt);

    PROTECT(out = Rf_allocVector(STRSXP, nlines));
    for (i = 0; i < nlines; i++) {
        const char *line = Rf_translateCharUTF8(STRING_ELT(lines, i));
        size_t len = strlen(line);
        uint64_t count;
        biosyn_span_t *spans = NULL;
        uint64_t needed;
        char *buf;

        count = biosyn_highlight_next_line(&state, line, (uint64_t)len, NULL, 0);
        if (count > 0) {
            if (count > (uint64_t)(SIZE_MAX / sizeof(*spans))) {
                UNPROTECT(1);
                Rf_error("too many highlight spans");
            }
            spans = (biosyn_span_t *)malloc((size_t)count * sizeof(*spans));
            if (!spans) {
                UNPROTECT(1);
                Rf_error("unable to allocate highlight spans");
            }
            if (biosyn_highlight_next_line(
                    &state, line, (uint64_t)len, spans, count) != count) {
                free(spans);
                UNPROTECT(1);
                Rf_error("libbiosyntax state changed during highlighting");
            }
        }

        needed = biosyn_render_ansi_line(
            line, (uint64_t)len, spans, count, NULL, 0
        );
        if (needed > (uint64_t)(SIZE_MAX - 1u)) {
            free(spans);
            UNPROTECT(1);
            Rf_error("rendered line is too large");
        }
        buf = (char *)malloc((size_t)needed + 1u);
        if (!buf) {
            free(spans);
            UNPROTECT(1);
            Rf_error("unable to allocate rendered output");
        }
        biosyn_render_ansi_line(
            line, (uint64_t)len, spans, count, buf, needed + 1u
        );
        SET_STRING_ELT(out, i, Rf_mkCharCE(buf, CE_UTF8));
        free(buf);
        free(spans);
    }
    UNPROTECT(1);
    return out;
}

SEXP C_biosyntax_spans(SEXP lines, SEXP format) {
    R_xlen_t i, nlines;
    biosyn_state_t state;
    biosyn_format_t fmt;
    SEXP out;

    check_lines(lines);
    fmt = parse_format(format);
    nlines = XLENGTH(lines);
    biosyn_state_init(&state, fmt);

    PROTECT(out = Rf_allocVector(VECSXP, nlines));
    for (i = 0; i < nlines; i++) {
        const char *line = Rf_translateCharUTF8(STRING_ELT(lines, i));
        size_t len = strlen(line);
        uint64_t count;
        biosyn_span_t *spans = NULL;
        SEXP one, start, length, class_id, names;
        R_xlen_t j;

        count = biosyn_highlight_next_line(&state, line, (uint64_t)len, NULL, 0);
        if (count > (uint64_t)R_XLEN_T_MAX) {
            UNPROTECT(1);
            Rf_error("too many highlight spans");
        }
        if (count > 0) {
            if (count > (uint64_t)(SIZE_MAX / sizeof(*spans))) {
                UNPROTECT(1);
                Rf_error("too many highlight spans");
            }
            spans = (biosyn_span_t *)malloc((size_t)count * sizeof(*spans));
            if (!spans) {
                UNPROTECT(1);
                Rf_error("unable to allocate highlight spans");
            }
            if (biosyn_highlight_next_line(
                    &state, line, (uint64_t)len, spans, count) != count) {
                free(spans);
                UNPROTECT(1);
                Rf_error("libbiosyntax state changed during highlighting");
            }
        }

        PROTECT(one = Rf_allocVector(VECSXP, 3));
        PROTECT(start = Rf_allocVector(REALSXP, (R_xlen_t)count));
        PROTECT(length = Rf_allocVector(REALSXP, (R_xlen_t)count));
        PROTECT(class_id = Rf_allocVector(INTSXP, (R_xlen_t)count));
        PROTECT(names = Rf_allocVector(STRSXP, 3));

        for (j = 0; j < (R_xlen_t)count; j++) {
            REAL(start)[j] = (double)spans[j].start;
            REAL(length)[j] = (double)spans[j].length;
            INTEGER(class_id)[j] = (int)spans[j].class_id;
        }
        SET_VECTOR_ELT(one, 0, start);
        SET_VECTOR_ELT(one, 1, length);
        SET_VECTOR_ELT(one, 2, class_id);
        SET_STRING_ELT(names, 0, Rf_mkChar("start"));
        SET_STRING_ELT(names, 1, Rf_mkChar("length"));
        SET_STRING_ELT(names, 2, Rf_mkChar("class_id"));
        Rf_setAttrib(one, R_NamesSymbol, names);
        SET_VECTOR_ELT(out, i, one);

        free(spans);
        UNPROTECT(5);
    }
    UNPROTECT(1);
    return out;
}

SEXP C_biosyntax_formats(void) {
    uint32_t count = biosyn_format_count();
    uint32_t i, j = 0;
    SEXP out, ids, names_v, descriptions, stateful, out_names;

    if (count <= 1u) {
        return R_NilValue;
    }
    PROTECT(out = Rf_allocVector(VECSXP, 4));
    PROTECT(ids = Rf_allocVector(INTSXP, count - 1u));
    PROTECT(names_v = Rf_allocVector(STRSXP, count - 1u));
    PROTECT(descriptions = Rf_allocVector(STRSXP, count - 1u));
    PROTECT(stateful = Rf_allocVector(LGLSXP, count - 1u));
    PROTECT(out_names = Rf_allocVector(STRSXP, 4));

    for (i = 1u; i < count; i++, j++) {
        biosyn_format_info_t info;
        if (!biosyn_format_info((biosyn_format_t)i, &info)) {
            UNPROTECT(6);
            Rf_error("unable to read libbiosyntax format metadata");
        }
        INTEGER(ids)[j] = (int)i;
        SET_STRING_ELT(names_v, j, Rf_mkCharCE(info.name, CE_UTF8));
        SET_STRING_ELT(descriptions, j, Rf_mkCharCE(info.description, CE_UTF8));
        LOGICAL(stateful)[j] = info.stateful ? TRUE : FALSE;
    }
    SET_VECTOR_ELT(out, 0, ids);
    SET_VECTOR_ELT(out, 1, names_v);
    SET_VECTOR_ELT(out, 2, descriptions);
    SET_VECTOR_ELT(out, 3, stateful);
    SET_STRING_ELT(out_names, 0, Rf_mkChar("id"));
    SET_STRING_ELT(out_names, 1, Rf_mkChar("name"));
    SET_STRING_ELT(out_names, 2, Rf_mkChar("description"));
    SET_STRING_ELT(out_names, 3, Rf_mkChar("stateful"));
    Rf_setAttrib(out, R_NamesSymbol, out_names);

    UNPROTECT(6);
    return out;
}

SEXP C_biosyntax_classes(void) {
    uint32_t count = biosyn_class_count();
    uint32_t i;
    SEXP out, ids, names_v, scopes, foreground, background, font_style, ansi_sgr;
    SEXP out_names;

    PROTECT(out = Rf_allocVector(VECSXP, 7));
    PROTECT(ids = Rf_allocVector(INTSXP, count));
    PROTECT(names_v = Rf_allocVector(STRSXP, count));
    PROTECT(scopes = Rf_allocVector(STRSXP, count));
    PROTECT(foreground = Rf_allocVector(STRSXP, count));
    PROTECT(background = Rf_allocVector(STRSXP, count));
    PROTECT(font_style = Rf_allocVector(STRSXP, count));
    PROTECT(ansi_sgr = Rf_allocVector(STRSXP, count));
    PROTECT(out_names = Rf_allocVector(STRSXP, 7));

    for (i = 0u; i < count; i++) {
        biosyn_class_info_t info;
        if (!biosyn_class_info((biosyn_class_t)i, &info)) {
            UNPROTECT(9);
            Rf_error("unable to read libbiosyntax class metadata");
        }
        INTEGER(ids)[i] = (int)i;
        SET_STRING_ELT(names_v, i, Rf_mkCharCE(info.name, CE_UTF8));
        SET_STRING_ELT(scopes, i, Rf_mkCharCE(info.scope, CE_UTF8));
        SET_STRING_ELT(foreground, i, Rf_mkCharCE(info.foreground, CE_UTF8));
        SET_STRING_ELT(background, i, Rf_mkCharCE(info.background, CE_UTF8));
        SET_STRING_ELT(font_style, i, Rf_mkCharCE(info.font_style, CE_UTF8));
        SET_STRING_ELT(ansi_sgr, i, Rf_mkCharCE(info.ansi_sgr, CE_UTF8));
    }
    SET_VECTOR_ELT(out, 0, ids);
    SET_VECTOR_ELT(out, 1, names_v);
    SET_VECTOR_ELT(out, 2, scopes);
    SET_VECTOR_ELT(out, 3, foreground);
    SET_VECTOR_ELT(out, 4, background);
    SET_VECTOR_ELT(out, 5, font_style);
    SET_VECTOR_ELT(out, 6, ansi_sgr);
    SET_STRING_ELT(out_names, 0, Rf_mkChar("id"));
    SET_STRING_ELT(out_names, 1, Rf_mkChar("name"));
    SET_STRING_ELT(out_names, 2, Rf_mkChar("scope"));
    SET_STRING_ELT(out_names, 3, Rf_mkChar("foreground"));
    SET_STRING_ELT(out_names, 4, Rf_mkChar("background"));
    SET_STRING_ELT(out_names, 5, Rf_mkChar("font_style"));
    SET_STRING_ELT(out_names, 6, Rf_mkChar("ansi_sgr"));
    Rf_setAttrib(out, R_NamesSymbol, out_names);

    UNPROTECT(9);
    return out;
}
