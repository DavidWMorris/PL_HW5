/*******************************************************************
        CS471 - Programming Languages
        Assignment #5 due: 3/3/2015
        Author: Morris, David (dmorris4@binghamton.edu)
        Date: 3/3/2015
*********************************************************************/
/*** Printing out the whole list:
      http://www.swi-prolog.org/FAQ/AllOutput.html
   
 *** To help you study for the test see:
       https://sites.google.com/site/prologsite/prolog-problems

   */

/* The only built-predicates you may use are:
     is, //, /, +, -, ^, *,=..,>, <,
     atom, is_list, functor, arg, integer, number, member, append
*/

/* 1: Below are 3 structures that representation expression trees.
      (Op is any Prolog operator.) This can be done in 3 clause.
      expTree does NOT have to be include as facts in the program.

     expTree(Op,Lt,Rt).
     expTree(lit,Value).
     expTree(Op,T).

    Write a Prolog program:
         eval(Tree,Value).
    which succeeds if Value is the result of computing the expressions
    represented by an expression tree.  For example:

   ?- eTree4(T),eval(T,V).
   T = expTree(float, expTree(sin, expTree(/, expTree(lit, pi), expTree(lit, 2))))
   V = 1.0

   ?- eTree1(T),eval(T,V).
   T = expTree(+, expTree(lit, 5), expTree(*, expTree(lit, 3), expTree(lit, 2)))
   V = 11.

   Below are trees you can use for testing.
*/

eval(expTree(lit,Value),Value).
eval(expTree(Op,T),Value) :- eval(T,X), Term =.. [Op,X], Value is Term.
eval(expTree(Op,Lt,Rt),Value) :- eval(Lt,X), eval(Rt,Y), Term =.. [Op,X,Y], Value is Term.

eTree1(expTree('+',
	      expTree(lit, 5),
	      expTree('*',
	           expTree(lit, 3),
	           expTree(lit, 2)
	       )
       )
 ).


eTree2(expTree('*',
	expTree('-',
	     expTree(lit, -3),
	     expTree(lit, 2)
	 ),

	expTree('+',
	      expTree(lit, 3),
	      expTree('-',
		     expTree(lit, 2)
		   )
	   )
	 )
 ).

eTree3(expTree('*',
	expTree('min',
	     expTree(lit, -3),
	     expTree(lit, 2)
	 ),

	expTree('+',
	     expTree(lit, 3),
	     expTree('-',
		    expTree(lit, 2)
		    )
	     )
	 )
 ).


eTree4(expTree(float,
	   expTree('sin',
	        expTree('/',
		       expTree(lit, pi),
		       expTree(lit, 2)
		     )
	    )
	   )
 ).

%


/* 2: evaluate/3 ---
      In the last homework we had the following problem:
      "Syntax-Directed Differentiation:  A motivating example illustrating the
         power of pattern matching in Prolog.
         Consider the following rules for symbolic differentiation
         (U, V are mathematical expressions, x is a variable):

        dx/dx = 1
        d(C)/dx = 0.
        d(Cx)/dx = C               (C is a constant)
        d(-U)/dx = -(dU/dx)
        d(U+V)/dx = dU/dx + dV/dx
        d(U-V)/dx = dU/dx - dV/dx
        d(U*V)/dx = U*(dV/dx) + V*(dU/dx)
        d(U^n)/dx = nU^(n-1)*(dU/dx)

        These rules can easily be translated into Prolog, for instance,
        the second rule can be defined as
                   d(C,x,0):-number(C).
          and the fifth rule can be defined as
                   d(U + V ,x, DU + DV)):-d(U,x,DU),d(V,x,DV). "

         My solution follows the comments.
      
      Keep in mind, though, that terms such as U+V are still trees with the
      functor operator at the root, and that evaluation of such terms requires
      additional processing which you will complete.

     Define the predicate, 'evaluate', that uses the result from
     differentiation (above) and a list of values for each variable and
     computes the resulting value. e.g.
    
     ?- d(3*(x +2*x*x),x,Result), VarValue = x:3 , evaluate(Result,Value,VarValue).
     Result = 3* (1+ (2*x*1+x*2))+ (x+2*x*x)*0,
     VarValue = x:3,
     Value = 39 ;
     Result = 3* (1+ (2*x*1+x* (2*1+x*0)))+ (x+2*x*x)*0,
     VarValue = x:3,
     Value = 39 ;
     false.

     ?- d((3*x) ^ 4,x,Result), VarValue = x:2 , evaluate(Result,Value,VarValue).
     Result = 4* (3*x)^3*3,
     VarValue = x:2,
     Value = 2592 ;
     Result = 4* (3*x)^3* (3*1+x*0),
     VarValue = x:2,
     Value = 2592 ;
     false.

 */

%Doesn't Work
evaluate(Result,Value,A:B) :- A = B, Value = Result.

d(x,x,1).
d(C,x,0):-number(C).
d(C*x,x,C):-number(C).
d(-U, X, -DU) :- d(U, X, DU).
d( U + V, x, RU + RV ):-d(U,x,RU), d(V,x,RV).
d( U - V, x, RU - RV ):-d(U,x,RU), d(V,x,RV).
d(U * V,x, U * DV + V * DU):- d(U,x,DU), d(V,x,DV).
d(U ^ N, x, N*U ^ N1*DU) :- integer(N), N1 is N-1, d(U, x, DU).




/** 3: Define a predicate concatALL(+NestedLists, -C), concatenate all the 
      elements in the NestedLists into a list C of only single terms.
   i.e.
   ?- concatALL([[1],[a,b,c],[],[100,91]],C).
   C = [1, a, b, c, 100, 91].
   ?- concatALL([[1],[a,[b,[c]],[]], [[[100],91],x] ],C). 
   C = [1, a, b, c, 100, 91, x].
   ?- concatALL([[],[foo(a),[[^,=,[+]],[c]],[]], [[[+(1,2)],91],*] ],C).
   C = [foo(a), ^, =, +, c, 1+2, 91, *] .

   This can be done in only 3 clauses.... think What NOT how. Order 
   of clauses matter.
*/

concatALL([],[]).
concatALL(A,C) :- not(is_list(A)), C = [A].
concatALL([H|T],C) :- concatALL(H,X), concatALL(T,Y), append(X,Y,C).

/* 4: Below is a database of US coins. */

coin(dollar, 100).
coin(half, 50).
coin(quarter, 25).
coin(dime,10).
coin(nickel,5).
coin(penny,1).



/* 4: Write a predicate change/2 that given the change amount, computes the ways
      in which we can give change.  Use USA's  coin denominations above.

      The predicate "change" is such that an positive integer S,
      change(S,T) "returns" a list of tuples, T, where the tuple contains the
      name of the denomination (Name,Count),
      the atom Name of the denomination and integer Count that gives
      the number of coins of each denomination in D that add up to S.
      For example::
        ?- change(127,L).
        L = [ (dollar, 1), (quarter, 1), (penny, 2)]
        Yes
        ?- change(44,L).
        L = [ (quarter, 1), (dime, 1), (nickel, 1), (penny, 4)] ;
        L = [ (quarter, 1), (dime, 1), (penny, 9)] ;
        L = [ (quarter, 1), (nickel, 3), (penny, 4)] ;
        L = [ (quarter, 1), (penny, 19)] ;
        L = [ (dime, 4), (penny, 4)] ;
        L = [ (nickel, 8), (penny, 4)] ;
        L = [ (penny, 44)] ;
        No

      The Coin Changing problem is an interesting problem usually studied in
      Algorthms.  http://condor.depaul.edu/~rjohnson/algorithm/coins.pdf is a
      nice discussion.
      Think about (no need to turn in)
         1) How could we generalize this problem to handle different
            denominations?
         2) What are the different techinques to find the change with the
            fewest number of coins ?
         3) What happens if the order of the "coin" facts change?

  */

%Doesn't Work
change(0,[]).
change(S,[(Name,Amount)|T]) :- coin(Name,X), change(Y,T), Z is Amount*X, S is Z+Y.

/*** 5: Do exercise 11.14 page 585.  You may define two predicates,
        one for the outer loop(2 clauses) -- insertionSort/3
        and one for the inner loop (3 clauses) -- insertE/3

      ?- insertionSort([4,67,2,1,8,3,0],L).
      L = [0, 1, 2, 3, 4, 8, 67] .
 ***/


insertionSort(Input,Sorted):-insertionSort(Input,[],Sorted).

