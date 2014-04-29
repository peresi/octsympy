%% Copyright (C) 2014 Colin B. Macdonald
%%
%% This file is part of OctSymPy
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
%% @deftypefn  {Function File}  {@var{g}} factor (@var{f})
%% @deftypefnx {Function File}  {@var{p,m}} factor (@var{f})
%% Factor a symbolic polynomial or integer
%%
%% @seealso{expand}
%% @end deftypefn

%% Author: Colin B. Macdonald
%% Keywords: symbolic

function [p,m] = factor(f)


  if (isempty (findsymbols (f)))
    %% No syms, integer factorization
    if (nargout <= 1)
      if (~isscalar(f))
        error('FIXME: check SMT, allows array input here?')
      end
      % FIXME: this is fragile, even pretty(y) causes it to expand
      % SMT is less fragile.   but how do they expose vector output?
      % They don't, how strange, given Matlab's factor(double) command!
      evalpy('p = factorint(i0, visual=True);;', f)
    else
      if (~isscalar(f))
        error('vector output factorization only for scalar integers')
      end
      cmd = [ 'd = factorint(_ins[0], visual=False)\n' ...
              'num = len(d.keys())\n' ...
              'sk = sorted(d.keys())\n' ...
              'p = sp.Matrix(1, num, sk)\n' ...
              'm = sp.Matrix(1, num, lambda i,j: d[sk[j]])\n' ...
              'return (p,m)' ];
      [p,m] = python_cmd (cmd, f);
    end


  else
    %% symbols, polynomial factorization
    % FIXME; symvar? opional s2nd argument
    %evalpy('p = factor(f);;', f)
    cmd = [ 'p = factor(_ins[0])\n' ...
            'if isinstance(p, sp.ImmutableMatrix):\n' ...
            '    p = p.as_mutable()\n' ...
            'return (p,)' ];
    p = python_cmd (cmd, f);
  end
end



%!test
%! n = 152862;
%! [p,m] = factor(n);
%! [ps,ms] = factor(sym(n));
%! assert (isequal (p, ps))
%! assert (isequal (m, ms))

%!test syms x
%! assert( logical (factor(x^2 + 6*x + 5) == (x+5)*(x+1)))

%!test
%! syms x
%! f = [ x^4/2 + 5*x^3/12 - x^2/3     x^2 - 1      10];
%! g = [ x^2*(2*x - 1)*(3*x + 4)/12   (x+1)*(x-1)  10];
%! assert (isequal (factor(f), g))
