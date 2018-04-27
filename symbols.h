// Compiler Theory and Design
// Dr. Duane J. Jarc

template <typename T>
class Symbols
{
public:
	void insert(char* lexeme, T entry);
	bool find(char* lexeme, T& entry);
private:
	map<string, T> symbols;
};

template <typename T>
void Symbols<T>::insert(char* lexeme, T entry)
{
	string name(lexeme);
	bool alreadyExists = symbols.find(name);
	if (alreadyExists)
	{
		return alreadyExists;
	} else
	{
			symbols[name] = entry;
	}
	return alreadyExists;	
}

template <typename T>
bool Symbols<T>::find(char* lexeme, T& entry)
{
	string name(lexeme);
	typedef typename map<string, T>::iterator Iterator;
	Iterator iterator = symbols.find(name);
	bool found = iterator != symbols.end();
	if (found)
		entry = iterator->second;
	return found;
}
