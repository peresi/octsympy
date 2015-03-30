%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy.
%%
%% OctSymPy is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published
%% by the Free Software Foundation; either version 3 of the License,
%% or (at your option) any later version.
%%
%% This software is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty
%% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
%% the GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public
%% License along with this software; see the file COPYING.
%% If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn  {Function File} {@var{p} =} potential (@var{v})
%% @deftypefnx {Function File} {@var{p} =} potential (@var{v}, @var{x})
%% @deftypefnx {Function File} {@var{p} =} potential (@var{v}, @var{x}, @var{y})
%% Symbolic potential of a vector field.
%%
%% Return symbolic nan if the field has no potential (based on
%% checking if the Jacobian matrix of the field is nonsymmetric).
%%
%% @seealso{gradient}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function p = potential(v, x, y)

  assert (isvector(v), 'potential: defined for vector fields')

  if (nargin == 1)
    x = symvar(v);
  end

  % orient same as vec field
  x = reshape(x, size(v));

  if (nargin < 3)
    y = 0*x;
  end

  assert ((length(v) == length(x)) && (length(x) == length(y)), ...
          'potential: num vars must match vec length')

  cmd = { '(v, x, y) = _ins'
          'if not v.is_Matrix:'
          '    v = Matrix([v])'
          '    x = Matrix([x])'
          '    y = Matrix([y])'
          'G = v.jacobian(x)'
          'if not G.is_symmetric():'
          '    return S.NaN,'
          '_lambda = sympy.Dummy("lambda", real=True)'
          'q = y + _lambda*(x - y)'
          'vlx = v.subs([a for a in zip(list(x), list(q))], simultaneous=True)'
          'p = integrate((x-y).dot(vlx), (_lambda, 0, 1))'
          'return p.simplify(),' };
  % FIXME: [a for a in zip] is a hack for python 3: why is this
  % necessary?  SymPy bug?

  p = python_cmd (cmd, sym(v), x, sym(y));

end


%!shared x,y,z
%! syms x y z

%!test
%! % 1D
%! f = 3*x^2;
%! F = x^3;
%! assert (isequal (potential(f), F))
%! assert (isequal (potential(f, x), F))
%! assert (isequal (potential(f, x, 0), F))
%! assert (isequal (potential(f, x, 2), F - 8))

%!test
%! F = x*exp(y) + (z-1)^2;
%! f = gradient(F);
%! G = potential(f, [x;y;z], [0;1;1]);
%! assert (isAlways (G == F))

%!test
%! F = x*exp(y);
%! f = gradient(F);
%! G = potential(f);
%! assert (isAlways (G == F))

%!test
%! % no potential exists
%! syms x y
%! a = [x; x*y^2];
%! assert (isnan (potential (a)))


%!shared

%!xtest
%! % fails b/c of sympy #8458 (piecewise expr that should simplify)
%! syms x
%! f = cos(x);
%! assert (isequal (potential(f, x), sin(x)))
