%{
#include <stdio.h>
#include <stdlib.h>

int keyword_count = 0;
int identifier_count = 0;
int number_count = 0;
int special_char_count = 0;
int line_number = 1;
int comment = 0;
int integer_count = 0;
int float_count = 0;
int operator_count = 0;
int datatype_count = 0;
int delimiter_count = 0;
int string_count = 0;

FILE *output;

int yywrap() {
    return 1;
}


%}

DIGIT          [0-9]
LETTER         [A-Za-z_]
STRING         \"[^\"]*\"
IDENTIFIER     {LETTER}({LETTER}|{DIGIT})*
FLOAT          {DIGIT}+"."{DIGIT}+
INTEGER        {DIGIT}+
OPERATOR       [-+*/=<>!&|]
DELIMITER      [,\(\)\[\]\{\}\\]
SPECIAL_CHAR   [\*;:\%\"']
DATATYPE       integer_number|floating_number|letter|sentence
KEYWORD        loop|start|condition|increment|by|when|greater|than|or|otherwise|identical|display
SLC            "//".*
MLC            "/*"([^*]|\*+[^*/])*\*+"/"

%%

\n                      { line_number++; }
[ \t\r]+                { }

{KEYWORD}               {
                          keyword_count++;
                          fprintf(output, "Keyword        (line %3d) --> %s\n", line_number, yytext);
                        }

{DATATYPE}              {
                          datatype_count++;
                          fprintf(output, "Data Type      (line %3d) --> %s\n", line_number, yytext);
                        }

{SLC}                   {
                          comment++;
                          fprintf(output, "Single-line Comment (line %3d) --> %s\n", line_number, yytext);
                        }

{MLC}                   {
                          comment++;
                          fprintf(output, "Multi-line Comment (line %3d) --> %s\n", line_number, yytext);
                        }

{IDENTIFIER}            {
                          identifier_count++;
                          fprintf(output, "Identifier     (line %3d) --> %s\n", line_number, yytext);
                        }

{STRING}                {
                          string_count++;
                          fprintf(output, "String         (line %3d) --> %s\n", line_number, yytext);
                        }

{FLOAT}                 {
                          number_count++;
                          float_count++;
                          fprintf(output, "Float Number   (line %3d) --> %s\n", line_number, yytext);
                        }

{INTEGER}               {
                          number_count++;
                          integer_count++;
                          fprintf(output, "Integer Number (line %3d) --> %s\n", line_number, yytext);
                        }

'[^']'                  {
                          fprintf(output, "Character      (line %3d) --> %s\n", line_number, yytext);
                        }

{SPECIAL_CHAR}          {
                          special_char_count++;
                          fprintf(output, "Special Char   (line %3d) --> %s\n", line_number, yytext);
                        }

{DELIMITER}             {
                          delimiter_count++;
                          fprintf(output, "Delimiter      (line %3d) --> %s\n", line_number, yytext);
                        }

{OPERATOR}              {
                          operator_count++;
                          fprintf(output, "Operator       (line %3d) --> %s\n", line_number, yytext);
                        }

.                       {
                          fprintf(output, "Syntax Error   (line %3d) --> Unrecognized token '%s'\n", line_number, yytext);
                        }

%%

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: ./a.out <input file> <output file>\n");
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        printf("Error opening input file.\n");
        return 1;
    }

    output = fopen(argv[2], "w");
    if (!output) {
        printf("Error opening output file.\n");
        fclose(input);
        return 1;
    }

    yyin = input;
    yylex();

    fprintf(output, "\nSummary:\n");
    fprintf(output, "------------------------------------\n");
    fprintf(output, "Keywords         --> %d\n", keyword_count);
    fprintf(output, "Identifiers      --> %d\n", identifier_count);
    fprintf(output, "Numbers          --> %d\n", number_count);
    fprintf(output, "  --> Integers   --> %d\n", integer_count);
    fprintf(output, "  --> Floats     --> %d\n", float_count);
    fprintf(output, "Strings          --> %d\n", string_count);
    fprintf(output, "Special Chars    --> %d\n", special_char_count);
    fprintf(output, "Delimiters       --> %d\n", delimiter_count);
    fprintf(output, "Operators        --> %d\n", operator_count);
    fprintf(output, "Datatypes        --> %d\n", datatype_count);
    fprintf(output, "Comments         --> %d\n", comment);
    fprintf(output, "------------------------------------\n");

    fclose(input);
    fclose(output);
    return 0;
}
