import com.comsol.model.*
import com.comsol.model.util.*

ModelUtil.clear;

model = ModelUtil.create('Model');

model.modelPath('C:\Users\huberttreve\Documents\COMSOL\PFAS_Model\to_hpg\Model + Validation');

model.label('Model.mph');

model.param.set('v', '50[m^3/h]/(pi*(D_i^2)/4)');
model.param.set('L', '1[m]');
model.param.set('D_i', '1.5[m]');
model.param.set('rho_s', '500[kg/m^3]/(1-eb)');
model.param.set('eb', '0.35');
model.param.set('rp', 'dp/2');
model.param.set('dp', '0.0038[m]');
model.param.set('Dm', '5.46E-10[m^2/s]');
model.param.set('mui', '1.004[mm^2/s]');
model.param.set('Co', '100*1e3*1e-9[g/L]/MM1');
model.param.set('MM1', '414.06[g/mol]');
model.param.set('Dl', '(2*v*rp)*(0.5+(20/(Re*Sc)))');
model.param.set('q_sat', '0.39[mol/kg]', 'saturation value on q in L model');
model.param.set('b_o1', '18[m^3/mol]', 'overall MTC for N2');
model.param.set('Sc', 'mui/Dm');
model.param.set('Sh', '(1.09/eb)*(Re^0.33)*(Sc^0.33)');
model.param.set('Re', '(v*dp*eb)/mui');
model.param.set('k', '(Dm/dp)*Sh');
model.param.set('a', '(3/(dp/2))');
model.param.set('K', 'k*a');
model.param.label('General Parameters');

model.component.create('comp1', true);

model.component('comp1').geom.create('geom1', 1);

model.component('comp1').mesh.create('mesh1');

model.component('comp1').geom('geom1').lengthUnit('cm');
model.component('comp1').geom('geom1').create('i1', 'Interval');
model.component('comp1').geom('geom1').feature('i1').set('coord', {'0' 'L'});
model.component('comp1').geom('geom1').create('pt1', 'Point');
model.component('comp1').geom('geom1').feature('pt1').set('p', {'0.2*L'});
model.component('comp1').geom('geom1').create('pt2', 'Point');
model.component('comp1').geom('geom1').feature('pt2').set('p', {'0.8*L'});
model.component('comp1').geom('geom1').run;
model.component('comp1').geom('geom1').run('fin');

model.component('comp1').variable.create('var1');
model.component('comp1').variable('var1').set('q1_sat', '(q_sat*b_o1*c)/(1+(b_o1*c))');

model.component('comp1').physics.create('scdeq', 'StabilizedConvectionDiffusionEquation', 'geom1');
model.component('comp1').physics('scdeq').field('none').field('c');
model.component('comp1').physics('scdeq').prop('Units').set('DependentVariableQuantity', 'none');
model.component('comp1').physics('scdeq').prop('Units').set('CustomDependentVariableUnit', 'mol/m^3');
model.component('comp1').physics('scdeq').create('flux1', 'FluxSource', 0);
model.component('comp1').physics('scdeq').feature('flux1').selection.set([1]);
model.component('comp1').physics.create('scdeq2', 'StabilizedConvectionDiffusionEquation', 'geom1');
model.component('comp1').physics('scdeq2').field('none').field('q');
model.component('comp1').physics('scdeq2').prop('Units').set('DependentVariableQuantity', 'none');
model.component('comp1').physics('scdeq2').prop('Units').set('CustomDependentVariableUnit', 'mol/kg');

model.component('comp1').mesh('mesh1').create('edg1', 'Edge');
model.component('comp1').mesh('mesh1').create('edg2', 'Edge');
model.component('comp1').mesh('mesh1').create('ref1', 'Refine');
model.component('comp1').mesh('mesh1').feature('edg1').selection.geom('geom1', 1);
model.component('comp1').mesh('mesh1').feature('edg1').selection.set([2]);
model.component('comp1').mesh('mesh1').feature('edg2').selection.geom('geom1', 1);
model.component('comp1').mesh('mesh1').feature('edg2').selection.set([1 3]);
model.component('comp1').mesh('mesh1').feature('ref1').selection.geom('geom1', 1);
model.component('comp1').mesh('mesh1').feature('ref1').selection.set([1 3]);

model.component('comp1').view('view1').axis.set('xmin', -0.49797821044921875);
model.component('comp1').view('view1').axis.set('xmax', 10.457540512084961);

model.component('comp1').physics('scdeq').label('fluid phase balance');
model.component('comp1').physics('scdeq').prop('Units').set('CustomSourceTermUnit', 'mol/(s*m^3)');
model.component('comp1').physics('scdeq').prop('ConsistentStabilization').set('limitTimeStepInStabilization', true);
model.component('comp1').physics('scdeq').feature('cdeq1').set('c', {'Dl'; '0'; '0'; '0'; 'Dl'; '0'; '0'; '0'; 'Dl'});
model.component('comp1').physics('scdeq').feature('cdeq1').set('al', {'v'; '0'; '0'});
model.component('comp1').physics('scdeq').feature('cdeq1').set('f', '-((1-eb)/eb)*rho_s*qt');
model.component('comp1').physics('scdeq').feature('flux1').set('include_cbflux', false);
model.component('comp1').physics('scdeq').feature('flux1').set('g', 'v*Co');
model.component('comp1').physics('scdeq2').label('solid phase balance');
model.component('comp1').physics('scdeq2').prop('Units').set('CustomSourceTermUnit', 'mol/(kg*s)');
model.component('comp1').physics('scdeq2').feature('cdeq1').set('c', [0; 0; 0; 0; 0; 0; 0; 0; 0]);
model.component('comp1').physics('scdeq2').feature('cdeq1').set('f', 'K*(q1_sat-q)');

model.component('comp1').mesh('mesh1').feature('size').set('hauto', 1);
model.component('comp1').mesh('mesh1').feature('size').set('table', 'cfd');
model.component('comp1').mesh('mesh1').feature('ref1').set('numrefine', 5);
model.component('comp1').mesh('mesh1').run;

model.study.create('std1');
model.study('std1').create('time', 'Transient');

model.sol.create('sol1');
model.sol('sol1').attach('std1');

model.result.create('pg1', 'PlotGroup1D');
model.result.create('pg2', 'PlotGroup1D');
model.result('pg1').create('lngr1', 'LineGraph');
model.result('pg1').feature('lngr1').selection.set([1 2 3]);
model.result('pg2').create('lngr1', 'LineGraph');
model.result('pg2').feature('lngr1').selection.set([1 2 3]);
model.result('pg2').feature('lngr1').set('expr', 'q');

model.study('std1').feature('time').label('Adsorption');
model.study('std1').feature('time').set('tunit', 'd');
model.study('std1').feature('time').set('tlist', 'range(0,1,75)');
model.study('std1').feature('time').set('probefreq', 'tout');

model.sol('sol1').createAutoSequence('std1');

model.study('std1').runNoGen;

model.result('pg1').label('Dependent Variable (scdeq)');
model.result('pg1').set('xlabel', 'Arc length (cm)');
model.result('pg1').set('ylabel', 'Dependent variable (mol/m<sup>3</sup>)');
model.result('pg1').set('smooth', 'internal');
model.result('pg1').set('xlabelactive', false);
model.result('pg1').set('ylabelactive', false);
model.result('pg1').feature('lngr1').label('Line');
model.result('pg1').feature('lngr1').set('smooth', 'internal');
model.result('pg1').feature('lngr1').set('resolution', 'normal');
model.result('pg2').label('Dependent Variable (scdeq2)');
model.result('pg2').set('xlabel', 'Arc length (cm)');
model.result('pg2').set('ylabel', 'Dependent variable (mol/kg)');
model.result('pg2').set('smooth', 'internal');
model.result('pg2').set('xlabelactive', false);
model.result('pg2').set('ylabelactive', false);
model.result('pg2').feature('lngr1').label('Line');
model.result('pg2').feature('lngr1').set('smooth', 'internal');
model.result('pg2').feature('lngr1').set('resolution', 'normal');