-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	local nodeChar = getDatabaseNode().getParent();
	local sChar = nodeChar.getNodeName();
	DB.addHandler(sChar ..  ".abilities", "onChildUpdate", onStatUpdate);
end

function onClose()
	local nodeChar = getDatabaseNode().getParent();
	local sChar = nodeChar.getNodeName();
	DB.removeHandler(sChar ..  ".abilities", "onChildUpdate", onStatUpdate);
end

function onStatUpdate()
	for _,w in pairs(getWindows()) do
		w.onStatUpdate();
	end
end

function onFilter(w)
	return (DB.getValue(w.getDatabaseNode(), "showonminisheet", 0) ~= 0);
end
