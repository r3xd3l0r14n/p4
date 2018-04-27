// Compiler Theory and Design
// Duane J. Jarc

// This file contains the bodies of the type checking functions

#include <string>
#include <vector>

using namespace std;

#include "types.h"
#include "listing.h"

void checkAssignment(Types lValue, Types rValue, string message)
{
	if (lValue != MISMATCH && rValue != MISMATCH && lValue != rValue)
		appendError(GENERAL_SEMANTIC, "Type Mismatch on " + message);
}

Types checkArithmetic(Types left, Types right)
{
	if (left == MISMATCH || right == MISMATCH)
		return MISMATCH;
	if (left == BOOL_TYPE || right == BOOL_TYPE)
	{
		appendError(GENERAL_SEMANTIC, "Numeric Type Required");
		return MISMATCH;
	} else if (left == INT_TYPE && right == REAL_TYPE)
	{
		left = REAL_TYPE;
		appendError(GENERAL_SEMANTIC, "Mixing of reals and ints not allowed");
		return MISMATCH;
	} else if (left == REAL_TYPE && right == INT_TYPE)
	{
		right = REAL_TYPE;
		appendError(GENERAL_SEMANTIC, "Mixing of reals and ints not allowed");
		return MISMATCH;
	}
	return INT_TYPE;
}


Types checkLogical(Types left, Types right)
{
	if (left == MISMATCH || right == MISMATCH)
		return MISMATCH;
	if (left != BOOL_TYPE || right != BOOL_TYPE)
	{
		appendError(GENERAL_SEMANTIC, "Boolean Type Required");
		return MISMATCH;
	}
		return BOOL_TYPE;
	return MISMATCH;
}

Types checkRelational(Types left, Types right)
{
	if (checkArithmetic(left, right) == MISMATCH)
		return MISMATCH;
	return BOOL_TYPE;
}
Types checkIfThen(Types expression, Types s1, Types s2)
{
	if (expression != BOOL_TYPE)
	{
		appendError(GENERAL_SEMANTIC, "Boolean Type Required");
	}
		if (s1 != s2)
		{
			appendError(GENERAL_SEMANTIC, "Statements do not match");
			return MISMATCH;
	}
	return BOOL_TYPE;
}
Types checkREMOP(Types left, Types right)
{
	if (left == REAL_TYPE || right == REAL_TYPE)
	{
		appendError(GENERAL_SEMANTIC, "Integer Type Required");
		return MISMATCH;
	} else if (left == BOOL_TYPE || right == BOOL_TYPE)
	{
		appendError(GENERAL_SEMANTIC, "Integer Type Required");
		return MISMATCH;
	}
	return INT_TYPE;
}
Types checkCaseInt(Types left)
{
	if (left != INT_TYPE)
	{
		appendError(GENERAL_SEMANTIC, "Integer Type Required");
		return MISMATCH;
	}
}
