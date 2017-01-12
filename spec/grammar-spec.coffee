describe "Language C# package", ->

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-csharp")

  describe "C# grammar", ->
    grammar = null

    beforeEach ->
      runs ->
        grammar = atom.grammars.grammarForScopeName('source.cs')

    it "parses the grammar", ->
      expect(grammar).toBeDefined()
      expect(grammar.scopeName).toBe "source.cs"

    it "tokenizes variable type followed by comment", ->
      tokens = grammar.tokenizeLines """
      struct hi {
        byte q; //(
      }
      """

      expect(tokens[1][1]).toEqual value: 'byte', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'storage.type.cs']
      expect(tokens[1][5]).toEqual value: '//', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'comment.line.double-slash.cs']
      expect(tokens[1][6]).toEqual value: '(', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'comment.line.double-slash.cs']

      tokens = grammar.tokenizeLines """
      struct hi {
        byte q; /*(*/
      }
      """
      expect(tokens[1][1]).toEqual value: 'byte', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'storage.type.cs']
      expect(tokens[1][5]).toEqual value: '/*', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'comment.block.cs', 'punctuation.definition.comment.cs']
      expect(tokens[1][6]).toEqual value: '(', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'comment.block.cs']

    it "tokenizes method definitions correctly", ->
      {tokens} = grammar.tokenizeLine("void func()")
      expect(tokens[0]).toEqual value: 'void ', scopes: ['source.cs']
      expect(tokens[1]).toEqual value: 'func', scopes: ['source.cs', 'meta.method-call.cs', 'meta.method.cs']
      expect(tokens[2]).toEqual value: '(', scopes: ['source.cs', 'meta.method-call.cs', 'punctuation.definition.method-parameters.begin.cs']

      {tokens} = grammar.tokenizeLine("dictionary<int, string> func()")
      expect(tokens[5]).toEqual value: 'func', scopes: ['source.cs', 'meta.method-call.cs', 'meta.method.cs']
      expect(tokens[6]).toEqual value: '(', scopes: ['source.cs', 'meta.method-call.cs', 'punctuation.definition.method-parameters.begin.cs']

      {tokens} = grammar.tokenizeLine("void func(test = default_value)")
      expect(tokens[0]).toEqual value: 'void ', scopes: ['source.cs']
      expect(tokens[1]).toEqual value: 'func', scopes: ['source.cs', 'meta.method-call.cs', 'meta.method.cs']
      expect(tokens[2]).toEqual value: '(', scopes: ['source.cs', 'meta.method-call.cs', 'punctuation.definition.method-parameters.begin.cs']

    it "tokenizes method calls", ->
      {tokens} = grammar.tokenizeLine("a = func(1)")
      expect(tokens[1]).toEqual value: 'func', scopes: ['source.cs', 'meta.method-call.cs', 'meta.method.cs']
      expect(tokens[2]).toEqual value: '(', scopes: ['source.cs', 'meta.method-call.cs', 'punctuation.definition.method-parameters.begin.cs']

      {tokens} = grammar.tokenizeLine("func()")
      expect(tokens[0]).toEqual value: 'func', scopes: ['source.cs', 'meta.method-call.cs', 'meta.method.cs']
      expect(tokens[1]).toEqual value: '(', scopes: ['source.cs', 'meta.method-call.cs', 'punctuation.definition.method-parameters.begin.cs']

      {tokens} = grammar.tokenizeLine("func  ()")
      expect(tokens[0]).toEqual value: 'func', scopes: ['source.cs', 'meta.method-call.cs', 'meta.method.cs']
      expect(tokens[2]).toEqual value: '(', scopes: ['source.cs', 'meta.method-call.cs', 'punctuation.definition.method-parameters.begin.cs']

      {tokens} = grammar.tokenizeLine("func ()")
      expect(tokens[0]).toEqual value: 'func', scopes: ['source.cs', 'meta.method-call.cs', 'meta.method.cs']
      expect(tokens[2]).toEqual value: '(', scopes: ['source.cs', 'meta.method-call.cs', 'punctuation.definition.method-parameters.begin.cs']

    it "tokenizes strings in method calls", ->
      tokens = grammar.tokenizeLines """
        class F {
          a = C("1.1 10\\n");
        })
      """

      expect(tokens[1][5]).toEqual value: 'C', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'meta.method.cs']
      expect(tokens[1][6]).toEqual value: '(', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'punctuation.definition.method-parameters.begin.cs']
      expect(tokens[1][7]).toEqual value: '"', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'string.quoted.double.cs', 'punctuation.definition.string.begin.cs']
      expect(tokens[1][8]).toEqual value: '1.1 10', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'string.quoted.double.cs']
      expect(tokens[1][9]).toEqual value: '\\n', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'string.quoted.double.cs', 'constant.character.escape.cs']
      expect(tokens[1][10]).toEqual value: '"', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'string.quoted.double.cs', 'punctuation.definition.string.end.cs']
      expect(tokens[1][11]).toEqual value: ')', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'punctuation.definition.method-parameters.end.cs']

    it "tokenizes strings in classes", ->
      tokens = grammar.tokenizeLines """
        class a
        {
          b = c + "(";
        }
      """

      expect(tokens[2][5]).toEqual value: '"', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'string.quoted.double.cs', 'punctuation.definition.string.begin.cs']
      expect(tokens[2][6]).toEqual value: '(', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'string.quoted.double.cs']
      expect(tokens[2][7]).toEqual value: '"', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'string.quoted.double.cs', 'punctuation.definition.string.end.cs']
      expect(tokens[2][8]).toEqual value: ';', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs']

      tokens = grammar.tokenizeLines """
        class a
        {
          b(c(d = "Command e") string f)
          {
          }
        }
      """

      expect(tokens[2][6]).toEqual value: '"', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'meta.method-call.cs', 'string.quoted.double.cs', 'punctuation.definition.string.begin.cs']
      expect(tokens[2][7]).toEqual value: 'Command e', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'meta.method-call.cs', 'string.quoted.double.cs']
      expect(tokens[2][8]).toEqual value: '"', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'meta.method-call.cs', 'string.quoted.double.cs', 'punctuation.definition.string.end.cs']
      expect(tokens[2][11]).toEqual value: 'string ', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'storage.reference.type.cs']
      expect(tokens[2][12]).toEqual value: 'f', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs']

    it "tokenizes base class identifiers", ->
      tokens = grammar.tokenizeLines """
        class a : parent1, parent2 {}
      """

      expect(tokens[0][6]).toEqual value: 'parent1', scopes: ['source.cs', 'meta.class.cs', 'storage.type.cs']
      expect(tokens[0][8]).toEqual value: 'parent2', scopes: ['source.cs', 'meta.class.cs', 'storage.type.cs']

    it "tokenizes comments on class declaration lines", ->
      tokens = grammar.tokenizeLines """
        class a : parent1/*, parent2 */{}
      """

      expect(tokens[0][6]).toEqual value: 'parent1', scopes: ['source.cs', 'meta.class.cs', 'storage.type.cs']
      expect(tokens[0][7]).toEqual value: '/*', scopes: ['source.cs', 'meta.class.cs', 'comment.block.cs', 'punctuation.definition.comment.cs']
      expect(tokens[0][8]).toEqual value: ', parent2 ', scopes: ['source.cs', 'meta.class.cs', 'comment.block.cs']
      expect(tokens[0][9]).toEqual value: '*/', scopes: ['source.cs', 'meta.class.cs', 'comment.block.cs', 'punctuation.definition.comment.cs']

    it "tokenizes class annotations", ->
      tokens = grammar.tokenizeLines """
        [classAttrib]
        class a
        {
          doFoo()
          {
          }
        }
      """

      expect(tokens[0][0]).toEqual value: '[', scopes: ['source.cs', 'meta.annotation.cs', 'punctuation.section.annotation.begin.cs']
      expect(tokens[0][1]).toEqual value: 'classAttrib', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs']
      expect(tokens[0][2]).toEqual value: ']', scopes: ['source.cs', 'meta.annotation.cs', 'punctuation.section.annotation.end.cs']
      expect(tokens[1][0]).toEqual value: 'class', scopes: ['source.cs', 'meta.class.cs', 'meta.class.identifier.cs', 'storage.modifier.cs']

    it "tokenizes class property annotations", ->
      tokens = grammar.tokenizeLines """
        class a
        {
          [propAttrib]
          bool hasData { get; set; }
        }
      """

      expect(tokens[2][1]).toEqual value: '[', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'punctuation.section.annotation.begin.cs']
      expect(tokens[2][2]).toEqual value: 'propAttrib', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs']
      expect(tokens[2][3]).toEqual value: ']', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'punctuation.section.annotation.end.cs']
      expect(tokens[3][1]).toEqual value: 'bool', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'storage.type.cs']

    it "tokenizes method annotations", ->
      tokens = grammar.tokenizeLines """
        class a
        {
          [methodAttrib]
          doFoo()
          {
          }
        }
      """

      expect(tokens[2][1]).toEqual value: '[', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'punctuation.section.annotation.begin.cs']
      expect(tokens[2][2]).toEqual value: 'methodAttrib', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs']
      expect(tokens[2][3]).toEqual value: ']', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'punctuation.section.annotation.end.cs']
      expect(tokens[3][1]).toEqual value: 'doFoo', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method-call.cs', 'meta.method.cs']

    it "tokenizes method parameters", ->
      tokens = grammar.tokenizeLines """
        class a
        {
          void func(CustomType customType = CustomType.Prop) {}
        }
      """

      expect(tokens[2][5]).toEqual value: 'CustomType', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method.cs', 'meta.method.identifier.cs', 'storage.type.generic.cs']
      expect(tokens[2][7]).toEqual value: 'customType', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method.cs', 'meta.method.identifier.cs', 'variable.parameter.function.cs']
      expect(tokens[2][11]).toEqual value: 'CustomType.Prop', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.method.cs', 'meta.method.identifier.cs', 'storage.type.cs']

    it "tokenizes annotations with parameter expressions", ->
      tokens = grammar.tokenizeLines """
        [Date(typeof(DateType))]
      """

      expect(tokens[0][1]).toEqual value: 'Date', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs']
      expect(tokens[0][2]).toEqual value: '(', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'punctuation.definition.attribute.parameters.begin.cs']
      expect(tokens[0][3]).toEqual value: 'typeof(DateType)', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'entity.value.parameter.attribute.cs']
      expect(tokens[0][4]).toEqual value: ')', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'punctuation.definition.attribute.parameters.end.cs']

    it "tokenizes complex annotations", ->
      tokens = grammar.tokenizeLines """
        [Attrib1, Attrib2(posVar, "pos-lit", named1=val1, named2 = val2, named3="val3", named4 = "val.4")]
        class TestClass {}
      """

      expect(tokens[0][6]).toEqual value: 'posVar', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'entity.value.parameter.attribute.cs']
      expect(tokens[0][7]).toEqual value: ',', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'punctuation.definition.separator.parameter.cs']
      expect(tokens[0][10]).toEqual value: 'pos-lit', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'entity.value.parameter.attribute.cs']
      expect(tokens[0][14]).toEqual value: 'named1', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'entity.key.parameter.attribute.cs']
      expect(tokens[0][15]).toEqual value: '=', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'keyword.operator.assignment.cs']
      expect(tokens[0][16]).toEqual value: 'val1', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'entity.value.parameter.attribute.cs']
      expect(tokens[0][23]).toEqual value: 'val2', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'entity.value.parameter.attribute.cs']
      expect(tokens[0][29]).toEqual value: 'val3', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'entity.value.parameter.attribute.cs']
      expect(tokens[0][33]).toEqual value: 'named4', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'entity.key.parameter.attribute.cs']
      expect(tokens[0][38]).toEqual value: 'val.4', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'meta.attribute.parameters.body.cs', 'entity.value.parameter.attribute.cs']

      tokens = grammar.tokenizeLines """
        class a
        {
          [attrib1][attrib2]
          doFoo()
          {
          }
        }
      """

      expect(tokens[2][1]).toEqual value: '[', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'punctuation.section.annotation.begin.cs']
      expect(tokens[2][2]).toEqual value: 'attrib1', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs']
      expect(tokens[2][3]).toEqual value: ']', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'punctuation.section.annotation.end.cs']
      expect(tokens[2][4]).toEqual value: '[', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'punctuation.section.annotation.begin.cs']
      expect(tokens[2][5]).toEqual value: 'attrib2', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs']
      expect(tokens[2][6]).toEqual value: ']', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'punctuation.section.annotation.end.cs']

    it "tokenizes nested annotations", ->
      tokens = grammar.tokenizeLines """
        [parentClassAttrib]
        class ParentClass
        {
            [childClassAttrib]
            class childAttrib
            {
                [childClassPropAttrib]
                bool hasData { get; set; }
            }

            [methodAttrib]
            void addItem(string item)
            {}
        }
      """

      expect(tokens[0][1]).toEqual value: 'parentClassAttrib', scopes: ['source.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs']
      expect(tokens[3][2]).toEqual value: 'childClassAttrib', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs']
      expect(tokens[6][2]).toEqual value: 'childClassPropAttrib', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs']
      expect(tokens[10][2]).toEqual value: 'methodAttrib', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs']

    it "correctly tokenizes class properties", ->
      tokens = grammar.tokenizeLines """
        class a
        {
          bool hasData { get; set; }
        }
      """

      expect(tokens[2][1]).toEqual value: 'bool', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'storage.type.cs']
      expect(tokens[2][3]).toEqual value: 'hasData', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'entity.name.function.cs']
      expect(tokens[2][7]).toEqual value: 'get', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'meta.block.cs', 'keyword.other.cs']

      tokens = grammar.tokenizeLines """
        class TestClass
        {
            bool hasData
            {
                get
                {
                    return hasData;
                }
                set
                {
                    hasData = value;
                }
            }
        }
      """

      expect(tokens[2][1]).toEqual value: 'bool', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'storage.type.cs']
      expect(tokens[2][3]).toEqual value: 'hasData', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'entity.name.function.cs']
      expect(tokens[4][1]).toEqual value: 'get', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'meta.block.cs', 'keyword.other.cs']

    it "correctly tokenizes interface private property name implementations", ->
      tokens = grammar.tokenizeLines """
        class a
        {
          PropType[] Test<arg1, arg2>.Prop { get; set; }
        }
      """

      expect(tokens[2][1]).toEqual value: 'PropType[]', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'storage.type.cs' ]
      expect(tokens[2][3]).toEqual value: 'Test<arg1, arg2>.Prop', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'entity.name.function.cs']
      expect(tokens[2][7]).toEqual value: 'get', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'meta.block.cs', 'keyword.other.cs']

    it "correctly tokenizes class fields", ->
      tokens = grammar.tokenizeLines """
        class a
        {
          public string TestField;
        }
      """

      expect(tokens[2][1]).toEqual value: 'public', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'storage.modifier.cs']
      expect(tokens[2][3]).toEqual value: 'string', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'storage.type.cs']
      expect(tokens[2][5]).toEqual value: 'TestField', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'entity.name.variable.cs']

    it "correctly tokenizes class field annotations", ->
      tokens = grammar.tokenizeLines """
        class a
        {
          [FieldAttrib]
          private string TestField;
        }
      """

      expect(tokens[2][1]).toEqual value: '[', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'punctuation.section.annotation.begin.cs']
      expect(tokens[2][2]).toEqual value: 'FieldAttrib', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'meta.attribute.cs', 'entity.name.attribute.cs' ]
      expect(tokens[2][3]).toEqual value: ']', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.annotation.cs', 'punctuation.section.annotation.end.cs']

    it "correctly tokenizes class field nullable types", ->
      tokens = grammar.tokenizeLines """
        class a
        {
          public DateTime? TestDate;
          private int? TestInt;
        }
      """

      expect(tokens[2][1]).toEqual value: 'public', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'storage.modifier.cs']
      expect(tokens[2][3]).toEqual value: 'DateTime', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'storage.type.cs']
      expect(tokens[2][4]).toEqual value: '?', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'punctuation.storage.type.modifier.cs']
      expect(tokens[2][6]).toEqual value: 'TestDate', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'entity.name.variable.cs']
      expect(tokens[3][1]).toEqual value: 'private', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'storage.modifier.cs']
      expect(tokens[3][3]).toEqual value: 'int', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'storage.type.cs']
      expect(tokens[3][4]).toEqual value: '?', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'punctuation.storage.type.modifier.cs']
      expect(tokens[3][6]).toEqual value: 'TestInt', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.field.cs', 'entity.name.variable.cs']

    it "correctly tokenizes class property nullable types", ->
      tokens = grammar.tokenizeLines """
        class a
        {
          public DateTime? TestDate {};
          private int? TestInt {};
        }
      """

      expect(tokens[2][1]).toEqual value: 'public', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'storage.modifier.cs']
      expect(tokens[2][3]).toEqual value: 'DateTime', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'storage.type.cs']
      expect(tokens[2][4]).toEqual value: '?', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'punctuation.storage.type.modifier.cs']
      expect(tokens[3][1]).toEqual value: 'private', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'storage.modifier.cs']
      expect(tokens[3][3]).toEqual value: 'int', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'storage.type.cs']
      expect(tokens[3][4]).toEqual value: '?', scopes: ['source.cs', 'meta.class.cs', 'meta.class.body.cs', 'meta.property.cs', 'punctuation.storage.type.modifier.cs']

    describe "Preprocessor directives", ->
      directives = [ '#if DEBUG', '#else', '#elif RELEASE', '#endif',
        '#define PCL', '#undef NET45',
        '#warning Text warning', '#error Error warning',
        '#line 200 "Special"', '#line default', '#line hidden',
        '#region Name of region', '#endregion',
        '#pragma Warning disable 414, CS3021', '#pragma warning restore 414',
        '#pragma checksum "file.cs" "{3673e4ca-6098-4ec1-890f-8fceb2a794a2}" "{012345678AB}"' ]
      locations = [ '$preprocessor', 'using A;\n$preprocessor\nusing B;',
        'namespace A {\n$preprocessor\n}', 'namespace A {\nclass B {\n$preprocessor\n}\n}',
        'class B{\npublic void A(){\n$preprocessor\n}\n}',
        'class B {\npublic bool Prop {\nget{\n$preprocessor\nreturn true;\n}\n}' ]
      leadings = [ '    ', ' ', '\t\t' ]

      it "parses in correct locations", ->
        for directive in directives
          for location in locations
            tokens = grammar.tokenizeLines location.replace '$preprocessor', directive
            token = tokens[location.split('\n').indexOf('$preprocessor')]

            expect(token[0].scopes).toContain('meta.preprocessor.cs')
            expect(token[0].scopes).toContain('meta.directive.preprocessor.cs')

            firstSpaceAt = directive.indexOf(' ')
            if firstSpaceAt > 0
              expect(token[0].value).toBe(directive.slice(0, firstSpaceAt))
              expect(token[2].value.trim()).toBe(directive.slice(firstSpaceAt + 1))
              expect(token[2].scopes).toContain('meta.preprocessor.cs')
              expect(token[2].scopes).toContain('entity.name.preprocessor.cs')
            else
              expect(token[0].value).toBe(directive)

      it "parses in correct locations with leading whitespace", ->
        for directive in directives
          for location in locations
            for leading in leadings
              tokens = grammar.tokenizeLines location.replace '$preprocessor', leading + directive
              token = tokens[location.split('\n').indexOf('$preprocessor')]

              expect(token[1].scopes).toContain('meta.preprocessor.cs')
              expect(token[1].scopes).toContain('meta.directive.preprocessor.cs')

              firstSpaceAt = directive.indexOf(' ')
              if firstSpaceAt > 0
                expect(token[1].value).toBe(directive.slice(0, firstSpaceAt))
                expect(token[3].value.trim()).toBe(directive.slice(firstSpaceAt + 1))
                expect(token[3].scopes).toContain('meta.preprocessor.cs')
                expect(token[3].scopes).toContain('entity.name.preprocessor.cs')
              else
                expect(token[1].value).toBe(directive)

      it "parses in correct locations with trailing line comment", ->
        for directive in directives
          for location in locations
            tokens = grammar.tokenizeLines location.replace '$preprocessor', (directive + ' // A line comment')
            token = tokens[location.split('\n').indexOf('$preprocessor')]

            expect(token[0].scopes).toContain('meta.preprocessor.cs')
            expect(token[0].scopes).toContain('meta.directive.preprocessor.cs')

            firstSpaceAt = directive.indexOf(' ')
            if firstSpaceAt > 0
              expect(token[0].value).toBe(directive.slice(0, firstSpaceAt))
              expect(token[2].value.trim()).toBe(directive.slice(firstSpaceAt + 1))
              expect(token[2].scopes).toContain('meta.preprocessor.cs')
              expect(token[2].scopes).toContain('entity.name.preprocessor.cs')
            else
              expect(token[0].value).toBe(directive)

            expect(token[token.length - 3].value).toBe('//')
            expect(token[token.length - 3].scopes).toContain('comment.line.double-slash.cs')
            expect(token[token.length - 2].value).toBe(' A line comment')
            expect(token[token.length - 2].scopes).toContain('comment.line.double-slash.cs')
