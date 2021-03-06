function result=K_vector(K0,Kfzp,depth_interval,layer_num)
if nargin>4
    errordlg('Input arguements exceed');
elseif nargin<4
    errordlg('Not enough input arguments');
else
    
    result=zeros(layer_num);
    for i=1:layer_num
        result(i)=K0*exp(-Kfzp*(i-0.5)*depth_interval);
    end
end
end