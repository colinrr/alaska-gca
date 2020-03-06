function [seismos,ind] = group_select(group,w);
% use this to pull the indices of a specific group of stations out of the
% waveform, or just output the set of station codes
% IN:   group = group name
%                options:
%                   spurr
%                   redoubt
%                   iliamna
%                   fourpeaked
%                   augustine
%                   avoSW
%                   kenai
%                   NE
%                   moos
%                   mygroup
%                   initial
%                   all
%                   quick
%       w      = waveform [optional]. If not entered, will just output
%                group vector
%
% OUT:  seismos = cell array of station names
%       ind     = indices in waveform w. Returns [] if no w is input
if nargin<2
    w = [];
end

ind = [];

if     strcmp(group,'spurr');
%     seismos = {'BGL','BKG','CGL','CKL','CKN','CKT','CP2','CRP','NCG',...
%         'SPBG','SPNW','SPU','SPWE','STLK'};
    seismos = {'BGL','BKG','CGL','CKL','CKN','CKT','CP2','CRP','NCG',...
        'SPBG','SPCG','SPNW','SPU','SPWE','SPCR','STLK'};
elseif strcmp(group,'redoubt');
    seismos = {'RED','RDT','BGR','DFR','RDE','NCT','RDN','RDWB','RSO',...
        'RDJH','REF'};
elseif strcmp(group,'iliamna')
    seismos = {'ILW','ILI','INE','IVE','IVS','ILS'};
elseif strcmp(group,'fourpeaked')
    seismos = {'FONW','FOSS','FOPK'};
elseif strcmp(group,'augustine');
    seismos = {'AUNW','AUL','AUW','AUH','AUP','AUE','AUSE','AUI'};
elseif strcmp(group,'avoSW')
    seismos = {'PDB','OPT','BGM','MMN','CDD','SVI'}; %added SVI fordahelluvit
elseif strcmp(group,'kenai')%     seismos = {'BGL','BKG','CGL','CKL','CKN','CKT','CP2','CRP','NCG',...
%         'SPBG','SPNW','SPU','SPWE','STLK'};

    seismos = {'NKA','HOM','VOGL','SLK','BRLK','SWD','HEAD','LTI','RC01'...
        'PMR','SAW','NNL','PWL','CFI'};
elseif strcmp(group,'NE')
    seismos = {'SSN','SKN','FIB','TRAP','CUT','PPLA'};
elseif strcmp(group,'moos')
    seismos = {'ALPI','AVAL','BIGB','BLAK','DEVL','HEAD','HOPE','KASH',...
        'LSKI','LSUM','MPEN','NSKI','PERI','RUSS','SOLD','TUPA'};
elseif strcmp(group,'mygroup')
    seismos = {'SSN','SKN','FIB','TRAP','BIGB','KASH','BGL','BKG','CGL',...
        'CKN','CKT','CKL','CP2','CRP','NCG','SPBG','SPNW','SPU','SPWE',...
        'STLK','ALPI','FOSS','DFR'};
elseif strcmp(group,'initial')
    seismos = {'SKN','BGL','NCG','STLK','NKA','FOSS','TRAP','DFR','FIB'};
elseif strcmp(group,'all')
        ind = [1:length(w)];
% Add in groups for Redoubt explosions: plotting maps
elseif strcmp(group,'red2')
    seismos = {'BGL','BKG','CKL','CKN','CP2','CRP','NCG',...
        'SPBG','SPNW','SPU','SPWE','STLK','SSN','FIB','SKN','TRAP','FOSS',...
        'MPEN','BIGB','KASH','DFR'};
    disp('Get clear, Wedge, you can''t do any more good back there!')
elseif strcmp(group,'red5')
    seismos = {'BKG','BGL','DFR'};
    disp('The Force will be with you, always...')
elseif strcmp(group,'red12')
    seismos = {'BGL','SPWE','CRP','SPNW','SSN','SKN','FONW','FOSS','DFR'};
    disp('Red 12 standing by...')
elseif strcmp(group,'red13')
    seismos = {'FOSS','FONW','DFR'};
    disp('Red 13 standing by...')
% ----------------------------------
% QUICK SELECT
elseif strcmp(group,'quick')
    seismos = {'ALPI','AVAL','BIGB','BLAK','DEVL','HEAD','HOPE','KASH',...
        'LSKI','LSUM','MPEN','NSKI','PERI','RUSS','SOLD','TUPA','BGL','BKG','CGL','CKL','CKN','CKT','CP2','CRP','NCG',...
        'SPBG','SPNW','SPU','SPWE','STLK','SSN','SKN','FIB','TRAP','CUT','PPLA'};
%-----------------------------------
else
    sprintf('\nGroup not found\n')
end

if and(~strcmp(group, 'all'),~isempty(w) )
    for nn = 1:length(seismos)
        ii = find(strcmp(get(w,'station'),seismos{nn}));
      ind = [ind ii];
    end    
end
end