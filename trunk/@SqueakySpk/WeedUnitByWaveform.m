function varargout = WeedUnitByWaveform(varargin)
% WEEDUNITBYWAVEFORM M-file for WeedUnitByWaveform.fig
%      WEEDUNITBYWAVEFORM, by itself, creates a new WEEDUNITBYWAVEFORM or raises the existing
%      singleton*.
%
%      H = WEEDUNITBYWAVEFORM returns the handle to a new WEEDUNITBYWAVEFORM or the handle to
%      the existing singleton*.
%
%      WEEDUNITBYWAVEFORM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WEEDUNITBYWAVEFORM.M with the given input arguments.
%
%      WEEDUNITBYWAVEFORM('Property','Value',...) creates a new WEEDUNITBYWAVEFORM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WeedUnitByWaveform_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WeedUnitByWaveform_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WeedUnitByWaveform

% Last Modified by GUIDE v2.5 21-Jun-2010 22:16:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WeedUnitByWaveform_OpeningFcn, ...
                   'gui_OutputFcn',  @WeedUnitByWaveform_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before WeedUnitByWaveform is made visible.
function WeedUnitByWaveform_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WeedUnitByWaveform (see VARARGIN)

% Choose default command line output for WeedUnitByWaveform
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WeedUnitByWaveform wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = WeedUnitByWaveform_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PushGood.
function PushGood_Callback(hObject, eventdata, handles)
% hObject    handle to PushGood (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PushBad.
function PushBad_Callback(hObject, eventdata, handles)
% hObject    handle to PushBad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
