function tco = calculateNodeCost(capex,yearlyOpex,expectedLifespan,...
                    periodYears,multiplier)
%calculateNodeCost Returns total cost of a node over some period of time.
%   capex: the capital expenses to adquire this subsystem, in US
%          dollars. This will also add to the total cost of ownership
%          at year 0 (when it is initially purchased), plus when the
%          subsystem needs to be repurchased at the end of its usable life.
%   yearlyOpex: the yearly maintenance costs of this subsystem, in US 
%          dollars.
%   expectedLifespan: the expected usable life of this subsystem, in
%          years. At the end of this subsystem's usable life, the 
%          subsystem needs to be repurchased (at a cost defined by the 
%          capex)
%   periodYears: the length of the time period (in years) over which to
%          calculate total cost of ownership.
%   multiplier: some linear factor by which to multiply the entire total
%          cost of ownership

tco = (capex + (yearlyOpex*periodYears) + ... 
                    floor(periodYears/expectedLifespan)*capex)*multiplier;

end

