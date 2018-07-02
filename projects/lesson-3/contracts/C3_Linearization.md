C3 Linearization

contract O

contract A is O

contract B is O

contract C is O

contract K1 is A, B

contract K2 is A, C

contract Z is K1, K2


Result : L(Z) = [Z, K1, K2, A, B, C, O]

Calculation procedure:

L[Z] = [z] + merge(L(K1), L(K2), [K1, K2])

     = [Z] + merge([K1, A, B, O], [K2, A, C, O], [K1, K2])
     
     = [Z, K1] + merge([A, B, O], [K2, A, C, O], [K2])
     
     = [Z, K1, K2] + merge([A, B, O], [A, C, O])
     
     = [Z, K1, K2, A] + merge([B, O], [C, O)])
     
     = [Z, K1, K2, A, B] + merge([O], [C, O)])
     
     = [Z, K1, K2, A, B, C] + merge([O], [O])
     
     = [Z, K1, K2, A, B, C, O]

python3 validation code:

class Type(type):

    def __repr__(cls):
    
        return cls.__name__
        
A = Type('A', (object,), {})

B = Type('B', (object,), {})

C = Type('C', (object,), {})

K1 = Type('K1', (A, B), {})

K2 = Type('K2', (A, C), {})

Z = Type('Z', (K1, K2), {})

Z.mro()
