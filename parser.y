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

%type <type> type statement statement_ reductions expression relation term
	factor primary conjunct negation power

%%

function:
	function_header optional_variable body ;

function_header:
	FUNCTION IDENTIFIER RETURNS type ';';

optional_variable:
	variable |
	;

variable:
	IDENTIFIER ':' type IS statement_
		{checkAssignment($3, $5, "Variable Initialization");
		symbols.insert($1, $3);} ;

type:
	INTEGER {$$ = INT_TYPE;} |
  REAL {$$ = REAL_TYPE;} |
	BOOLEAN {$$ = BOOL_TYPE;} ;

body:
	BEGIN_ statement_ END ';' ;

statement_:
	statement ';' |
	error ';' {$$ = MISMATCH;} ;

statement:
	expression |
	REDUCE operator reductions ENDREDUCE {$$ = $3;} |
  IF expression THEN statement ELSE statement ENDIF ';' {$$ = $2} |
  CASE expression IS cases OTHERS ARROW statement ENDCASE ';' {$$ =$2} ;

operator:
	ADDOP |
	MULOP ;

cases:
  | cases case ;

case:
  WHEN INT_LITERAL ARROW statement ;

reductions:
	reductions statement_ {$$ = checkArithmetic($1, $2);} |
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
	factor MULOP power  {$$ = checkArithmetic($1, $3);} |
  factor REMOP power {$$ = checkArithmetic{$1, $3};} |
	power ;

power:
  negation EXPOP power {$$ = checkArithmetic($1, $3);} |
  negation ;

negation:
  NOTOP primary {$$ = $2} |
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
