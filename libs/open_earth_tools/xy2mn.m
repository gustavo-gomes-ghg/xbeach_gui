function varargout = xy2mn(x,y,xv,yv,varargin)
%XY2MN  get indices of random (x,y) points in curvilinear grid
%
%   [m,n] = xy2mn(x,y,xv,yv,<keyword,value>) 
%
% returns indices (m,n) of the curvilinear (x,y) 
% grid of points closest to the random points 
% (xv,yv) where m is the 1st, and  n is the 
% 2nd dimension of x and y. If multiple points are 
% equally near, one (m,n) combi is arbitrarily chosen.
%
% keyword 'Rmax' is the maximal distance taken into consideration.
% Default Inf, when empty, it is the max(sqrt) of all cells.
%
% Alternatives:
%  struct      = xy2mn(...) with fields m, n, mn and eps (match accuracy)
% [m,n,mn]     = xy2mn(...)
% [m,n,mn,eps] = xy2mn(...)
% where mn = the linear index, and eps the distance.
%
% for Delft3D: use the G.cend output from delft3d_io_grd to get the center 
% points of the grid with extrapolated dummy row/col: 1:nmax   x 1:mmax
%
% Example:
%   [x,y,z] = peaks;
%   nv = 100;
%   xv = -4+8*rand(nv,1);
%   yv = -4+8*rand(nv,1);
%   [m,n] = xy2mn(x,y,xv,yv,'Rmax',.5);
%   pcolor(x,y,z)
%   hold on
%   for i=1:length(m)
%      if isnan(m(i))
%      h(i) = plot(xv(i),yv(i),'x','markersize',20);
%      else
%      h(i) = scatter( xv(i),       yv(i),      100,z(m(i),n(i)),'filled');
%      plot([x(m(i),n(i)) xv(i)],[y(m(i),n(i)) yv(i)],'k.-')
%      end
%   end
%   set(h,'MarkerEdgeColor','k')
%   axis auto
%
% See also: SUB2IND, IND2SUB, FIND, MIN, MAX, GRIDDATA_NEAREST, delft3d_io_grd

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Feb 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xy2mn.m 6936 2012-07-16 12:26:48Z boer_g $
% $Date: 2012-07-16 09:26:48 -0300 (Mon, 16 Jul 2012) $
% $Author: boer_g $
% $Revision: 6936 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/grid_fun/xy2mn.m $
% $Keywords: $

OPT.Rmax  = Inf; % make this optionally same size as X and Y.

OPT  = setproperty(OPT,varargin{:});

mn   = zeros(size(xv));
m    = zeros(size(xv));
n    = zeros(size(xv));
mmax = size(x,1);

%method = 'curvilinear';
%
%switch method
%
%case 'unstructured'
%
%   z    = 1:prod(size(x));
%   z    = reshape(z,size(x));
%
%   %% TOO SLOW !!!!!!!!!
%
%   mask = ~isnan(x)&~isinf(x)&~isnan(y)&~isinf(y);
%   
%   for i=1:length(xv(:))
%      mn(i) = griddata(x(mask),y(mask),z(mask),xv(i),yv(i),'nearest');
%      % NOT zero based
%      m(i)  = mod(mn(i)-1,mmax)+1;
%      n(i)  = div(mn(i)-1,mmax)+1;
%      disp(['Processed ',num2str(i),' of ',num2str(length(xv(:))),...
%      ' mn = ',num2str(mn(i)),...
%      ' m = ' ,num2str(m (i)),...
%      ' n = ' ,num2str(n (i))])
%   end
%
%case 'curvilinear'

if isempty(OPT.Rmax)
  OPT.Rmax = nanmax(make1d(sqrt(grid_area(D.cen.x,D.cen.y))));
end

   accuracy  = zeros(size(xv)); % distance between matrix node and random point

   for i=1:length(xv(:))

      %% Get matrix of distances between random point and all matrix nodes
      dist = sqrt((x - xv(i)).^2 + ...
                  (y - yv(i)).^2);
                  
                  %pcolor(x,y,dist)
                  %colorbar
                  %pausedisp
                  %hold on
                  
      %% The (m,n) we are looking for is where this distance is minimal 

      [accuracies,mns] = min(dist(:));
      
      if length(accuracies) > 1 
         disp(['Point ',num2str(xv(i)),'',num2str(yv(i)),'has multiple matches in matrix, one is arbitrarily chosen.'])
      end
      
      accuracy(i) = accuracies(1);
      mn(i)       = mns(1);

      %% NOT zero based, can also use sub2ind here.
      if accuracy(i) < OPT.Rmax
      m(i)        = mod(mn(i)-1,mmax)+1;
      n(i)        = div(mn(i)-1,mmax)+1;
      else
      m(i)        = nan;
      n(i)        = nan;          
      end
   end

%end

%% Output

if nargout==1
   S.m   = m;
   S.n   = n;
   S.mn  = mn;
   S.eps = accuracy;
   varargout = {S};
elseif nargout==2
   varargout = {m,n};
elseif nargout==3
   varargout = {m,n,mn};
elseif nargout==4
   varargout = {m,n,mn,accuracy};
end

%% function intdiv
%-------------------------------
function intdiv = div(x,y)
%   DIV(x,y) floor(x./y) if y < 0.
%            ceil (x./y) if y > 0.
% - Number of times y fits into x.
% - Limits x to largets integer multiple of y 
%
% Note that rem  = mod in fortran
%           mod ~= mod in fortran

%  if x>=0
%   intdiv = floor(x./y);
%  elseif x<0
%   intdiv = ceil(x./y);
%  end

% SAME AS
  intdiv = sign(x).*sign(y).*floor(abs(x./y));