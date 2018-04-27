/* Compiler Theory and Design
   Duane J. Jarc */

%{

#include <string>
#include <vector>
#include <map>

using namespace std;

#include "types.h"
#include "listing.h"
#include "symbols.h"

int yylex();
void yyerror(const char* message);

Symbols<Types> symbols;

%}

%error-verbose

%union
{
	CharPtr iden;
	Types type;
}

%token <iden> IDENTIFIER
%token <type> INT_LITERAL BOOLEAN_LITERAL REAL_LITERAL

%token ADDOP MULOP RELOP ANDOP REMOP EXPOP OROP NOTOP
%token BEGIN_ BOOLEAN END ENDREDUCE FUNCTION INTEGER IS REDUCE RETURNS
%token REAL IF THEN ELSE ENDIF CASE OTHERS ARROW ENDCASE WHEN
%token NOT

%type <type> type statement statements reductions expression relation term
	factor primary conjunct negation power

%%

function:
	function_header variables body ;

function_header:
	FUNCTION IDENTIFIER RETURNS type ';' ;

variables:
  variable variables |
  ;

variable:
	IDENTIFIER ':' type IS statement
		{checkAssignment($3, $5, "Variable Initialization");
		symbols.insert($1, $3);} ;

type:
	INTEGER {$$ = INT_TYPE;} |
  REAL {$$ = REAL_TYPE;} |
	BOOLEAN {$$ = BOOL_TYPE;} ;

body:
	BEGIN_ statements END ';' ;

statements:
  statement statements |
  statement
  ;

statement:
	expression ';' |
	REDUCE operator reductions ENDREDUCE {$$ = $3;} |
  IF expression THEN statement ELSE statement ENDIF ';' {$$ = checkIfThen($2, $4, $6);} |
  CASE expression IS cases OTHERS ARROW statement ENDCASE ';' {$$ = checkCaseInt($2);} ;

operator:
	ADDOP |
	MULOP ;

cases:
  | cases case ;

case:
  WHEN INT_LITERAL ARROW statement ;

reductions:
	reductions statement {$$ = checkArithmetic($1, $2);} |
	{$$ = INT_TYPE;} ;

expression:
	expression OROP conjunct {$$ = checkLogical($1, $3);} |
	conjunct ;

conjunct:
  conjunct ANDOP relation {$$ = checkLogical($1, $3);} |
  relation ;

relation:
	relation RELOP term {$$ = checkRelational($1, $3);}|
	term ;

term:
	term ADDOP factor {$$ = checkArithmetic($1, $3);} |
	factor ;

factor:
	factor MULOP power {$$ = checkArithmetic($1, $3);} |
  factor REMOP power {$$ = checkREMOP($1, $3);} |
	power ;

power:
  power EXPOP negation {$$ = checkArithmetic($1, $3);} |
  negation ;

negation:
  NOTOP primary {$$ = $2;} |
  primary;

primary:
	'(' expression ')' {$$ = $2;} |
	INT_LITERAL | REAL_LITERAL | BOOLEAN_LITERAL |
	IDENTIFIER {if (!symbols.find($1, $$)) appendError(UNDECLARED, $1);} ;

%%

void yyerror(const char* message)
{
	appendError(SYNTAX, message);
}

int main(int argc, char *argv[])
{
	firstLine();
	yyparse();
	lastLine();
	return 0;
}
