OCB_INC   = 
OCB_FLAGS = 
OCB       = ocamlbuild $(OCB_FLAGS) $(OCB_INC)

all:
	$(OCB) test.native 
	export OCAMLRUNPARAM="b" && ./test.native

clean:
	$(OCB) -clean
