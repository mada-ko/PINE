function [subPixelShiftInRad] = calcTranslationParameters(positionList, data)
lenV = size(data,1);
lenH = size(data,2);

phV = 2*pi*ifftshift(fourierIdx(lenV))'/lenV;
phH = 2*pi*ifftshift(fourierIdx(lenH)) /lenH;

posIdx  = floor(positionList);
% pv = reshape(posIdx(:,1),1,1,[]);
% ph = reshape(posIdx(:,2),1,1,[]);
% idx = sub2ind(objectSize,repmat(pv+(1:lenV)',[1 lenH]),repmat(ph+(1:lenH),[lenV 1]));
% samplingIdx = uint32(idx);

posDeci = positionList - posIdx;
dv = reshape(posDeci(:,1),1,1,[]);
dh = reshape(posDeci(:,2),1,1,[]);
subPixelShiftInRad = dv.*phV + dh.*phH;
end

function idx = fourierIdx(len)
idx = -floor(len/2):floor(len/2)-mod(len+1,2);
end