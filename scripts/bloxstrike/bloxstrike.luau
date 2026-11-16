-- JNKIE UI Source: collect a key, then let the protected loader authenticate it.
local accessEnvironment=getgenv()
accessEnvironment.SCRIPT_KEY=nil
accessEnvironment.UI_CLOSED=false

local uiURL="https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
local downloaded,source=pcall(game.HttpGet,game,uiURL)
if not downloaded or type(source)~="string" or source=="" then source=game:HttpGet(uiURL,true) end
assert(type(source)=="string" and source~="","Unable to download the access interface")
local compile,problem=loadstring(source)
assert(compile,"Unable to compile the access interface: "..tostring(problem))
local library=compile()
local accessWindow=library:CreateWindow({
    Title="BloxStrike",Folder="BloxStrikeAccess",Icon="key-round",
    Size=UDim2.fromOffset(540,380),MinSize=Vector2.new(480,340),MaxSize=Vector2.new(680,500),
    Theme="Dark",Transparent=false,NewElements=true,
    OpenButton={Enabled=false},ToggleKey=Enum.KeyCode.RightShift,
})
local function keepEnglish(object)
    if object:IsA("GuiObject") then object.AutoLocalize=false end
end
local languageConnection=accessWindow.Parent.DescendantAdded:Connect(keepEnglish)
for _,object in ipairs(accessWindow.Parent:GetDescendants())do keepEnglish(object)end

local complete,cancelled,busy=false,false,false
local enteredKey=""
local accessTab=accessWindow:Tab({Title="Access",Icon="key-round",ShowTabTitle=true})
local status=accessTab:Paragraph({Title="Access key required",Desc="Get a key through JNKIE, paste it below, then select Continue."})
accessTab:Input({Title="Access key",Placeholder="Paste your JNKIE key",Value="",Callback=function(value)
    enteredKey=tostring(value or ""):match("^%s*(.-)%s*$")
end})
accessTab:Button({Title="Get key",Icon="external-link",Callback=function()
    if busy or complete then return end
    busy=true;status:SetDesc("Requesting your key link...")
    task.spawn(function()
        local ok,link=pcall(function()
            local sdkSource=game:HttpGet("https://jnkie.com/sdk/library.lua")
            local sdkLoader,sdkProblem=loadstring(sdkSource)
            assert(sdkLoader,sdkProblem)
            local sdk=sdkLoader()
            sdk.service="BloxStrike WindUI"
            sdk.identifier="1234166"
            sdk.provider="BloxStrike - LootLabs"
            local url,message=sdk.get_key_link()
            assert(type(url)=="string" and url:match("^https://"),message or "Key link unavailable")
            return url
        end)
        busy=false
        if complete then return end
        if not ok then status:SetDesc("Unable to get a key link. Try again shortly.");return end
        local copied=type(setclipboard)=="function" and pcall(setclipboard,link)
        status:SetDesc(copied and "Key link copied. Open it in your browser, complete the steps, and paste the key here." or link)
    end)
end})
accessTab:Button({Title="Continue",Icon="arrow-right",Callback=function()
    if complete or busy then return end
    if enteredKey=="" or #enteredKey>512 then status:SetDesc("Paste a valid key before continuing.");return end
    complete=true
end})
accessTab:Button({Title="Cancel",Icon="x",Callback=function()
    if complete then return end
    cancelled=true;complete=true
end})
local function closeAccess()
    if not complete then cancelled=true;complete=true end
end
accessWindow:OnClose(closeAccess)
accessWindow:OnDestroy(closeAccess)
repeat task.wait()until complete
languageConnection:Disconnect()
accessWindow:Destroy()
if cancelled then
    accessEnvironment.UI_CLOSED=true
    return
end
-- Do not pre-validate: the protected loader must validate one-time keys only once.
accessEnvironment.SCRIPT_KEY=enteredKey

do ("JNKIE Loader - Unauthorized tampering or debugging of protected scripts is strictly prohibited and may result in a global blacklist from JNKIE protected scripts."):sub(1,1);local k=getgenv().SCRIPT_KEY or SCRIPT_KEY;local m="Could not load the script. Check your internet connection and try again later.";local function v(h)warn(h);task.spawn(function()pcall(function()game:GetService("Players").LocalPlayer:Kick(h)end);task.wait();pcall(function()local p=game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ErrorPrompt;p.TitleFrame.ErrorTitle.Text="JNKIE";p.MessageArea.ErrorFrame.ErrorMessage.Text=h end)end)end;local r=(type(syn)=="table" and type(syn.request)=="function" and syn.request)or(type(request)=="function" and request)or(type(http_request)=="function" and http_request)or(type(http)=="table" and type(http.request)=="function" and http.request);if type(k)~="string" then v("No key provided. Get a key from the script provider, enter it, then try again.");return end;if type(r)~="function" then warn(m);return end;local function q(o)local d,a,x;task.spawn(function()a,x=pcall(r,o);d=true end);local s=os.clock();repeat task.wait()until d or os.clock()-s>15;if not d then return false,nil end;return a,x end;local a,x=q({Url="https://api.jnkie.com/api/v1/luascripts/delivery/b7543b2bbfe1bb9ef1c6dec008b06e498a7bb3cd55648fceefd68367e0ac7ff0?v=2&errors=text",Method="POST",Headers={["Content-Type"]="text/plain"},Body=k});local h=a and type(x)=="table" and type(x.Body)=="string" and(x.StatusCode==400 or x.StatusCode==401 or x.StatusCode==403)and x.Body;if h then local c,n=h:match("^([^\r\n]+)\n([^\r\n]+)$");c=c or h;if#c<=75 and(c=="LDR-DENIED"or c:match("^LDR%-DENIED:[A-Z_]+$"))then if not n or#n>512 then n=m;if k==""or k:match("^%s*$")then n="No key provided. Get a key from the script provider, enter it, then try again." end end;v(n.." ("..c..")");return end end;if a and type(x)=="table" and x.StatusCode==200 and type(x.Body)=="string" and (string.sub(x.Body,1,8)=="https://") then a,x=q({Url=x.Body,Method="GET"})end;if a and type(x)=="table" and(x.StatusCode==302 or x.StatusCode==303)then local h=x.Headers or x.headers;local l=type(h)=="table" and(h.Location or h.location);if type(l)=="string" and (string.sub(l,1,8)=="https://") then a,x=q({Url=l,Method="GET"})end end;if not a or type(x)~="table" or x.StatusCode~=200 or type(x.Body)~="string" or#x.Body==0 then warn(m);return end;local b=x.Body;x=nil;local f=loadstring(b);b=nil;if type(f)~="function" then warn(m);return end;f()end
