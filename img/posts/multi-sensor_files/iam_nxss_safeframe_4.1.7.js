/* do not edit variables below */
var expandedWidth = 670,
    expandedHeight = 420,
    iam_ng_mediapath = iam_protocol+"://"+iam_cdn_host+"/"+iam_cdn_path+"/",
    iam_ng_wm="0",
    iam_ng_ValidWMID = iam_ng_CalcWMID(),
    iam_ng_isInGIF = "/do/nosample.gif?z="+iam_ng_ValidWMID,
    iam_ng_resolveQSGIF = "/do/deliver.gif",
    iam_ng_invitationGIF = "/do/show.gif",
    iam_ng_openPopup = "/do/start.html",
    iam_ng_recheckIntervall = 86400000,
    iam_ng_host = window.location.protocol+"//qs.ioam.de",
    iam_ng_closeGIF = "/do/cancel.gif",
    iam_ng_laterGIF = "/do/later.gif",
    iam_ng_optoutGIF = "/do/optout.gif",
    iam_ng_Vers = "iam_de_nxss_yahoo_4.1.7",
    iam_ng_vis = 1,
    iam_ng_fadeout = "0",
    SITELOGO_NG = iam_ng_mediapath+"site.jpg",
    body = document.getElementsByTagName('body')[0],
    iam_ng_div = document.createElement("div"),
    szmvars="",
    iam_ng_scroll_top = 0,
    iam_ng_scroll_left = 0,
    iam_ng_rm_1,
    iam_ng_rm_2,
    iam_ng_rm_3,
    iam_ng_rm_4,
    iam_ng_rm_5,
    iam_layer="";


var Y = window.Y,
    useYAPI = true;

  if(!(Y && Y.SandBox && Y.SandBox.vendor)) {
    useYAPI = false;
  } else if(!Y.SandBox.vendor.supports('lyr')) {
    useYAPI = false;
  }


if(useYAPI) {

  var iam_ng_position_left = 0;
  var iam_ng_position_top = 0;
} else {

  var IAMRange = new Array(30,120,30,120);
  var VisRange = new Array(0,0,600,600);



  if(typeof iam_ng_fadeout_flash == "undefined") {
    var iam_ng_fadeout_flash = true;
  } else {
    if(typeof iam_ng_fadeout_flash != "boolean") {
      iam_ng_fadeout_flash = true;
    }
  }
  if(typeof iam_ng_fadeout_iframe == "undefined") {
    var iam_ng_fadeout_iframe = true;
  } else {
    if(typeof iam_ng_fadeout_iframe != "boolean") {
      iam_ng_fadeout_iframe = true;
    }
  }
  if(typeof iam_ng_fadeout_form == "undefined") {
    var iam_ng_fadeout_form = true;
  } else {
    if(typeof iam_ng_fadeout_form != "boolean") {
      iam_ng_fadeout_form = true;
    }
  }
  if(!iam_ng_fadeout_flash || !iam_ng_fadeout_iframe || !iam_ng_fadeout_form) {
    iam_ng_fadeout = "1";
  }
  if(typeof iam_ng_position_top == "undefined") {
    var iam_ng_position_top = 120;
  } else {
    if(typeof iam_ng_position_top != "number") {
      iam_ng_position_top = 120;
    }
    if(iam_ng_position_top < 0 || iam_ng_position_top > 600) {
      iam_ng_position_top = 120;
    }
  }
  if(typeof iam_ng_position_left == "undefined") {
    var iam_ng_position_left = 30;
  } else {
    if(typeof iam_ng_position_left != "number") {
      iam_ng_position_left = 30;
    }
    if(iam_ng_position_left < 0 || iam_ng_position_left > 600) {
      iam_ng_position_left = 30;
    }
  }
  if(typeof iam_ng_zindex == "undefined") {
    var iam_ng_zindex = 10000000000;
  } else {
    if(typeof iam_ng_zindex != "number") {
      iam_ng_zindex = 10000000000;
    }
    if(iam_ng_zindex < 10000000000) {
      iam_ng_zindex = 10000000000;
    }
  }

}

function iam_ng_isActive() {
  var szmvar_c=0;
  if(navigator.cookieEnabled){
    var szmvar_cook = document.cookie.split(";");
    for(var szmvar_i=0;szmvar_i<szmvar_cook.length;szmvar_i++) {
      if(szmvar_cook[szmvar_i].match("POPUPCHECK=.*")) {
        var szmvar_check=new Date();
        var szmvar_now=szmvar_check.getTime();
        szmvar_check.setTime(szmvar_cook[szmvar_i].split("=")[1]);
        if(szmvar_check.getTime() >= (szmvar_now)) szmvar_c=1;
        break;
      }
    }
  }
  return szmvar_c==0;
}

function iam_ng_isClientSampleMember(iam_ng_hostadd) {
  iam_ng_host = iam_ng_hostadd;

  var iamimg = new Image();
  iamimg.src= iam_ng_host+iam_ng_isInGIF;
  iamimg.onerror = iam_ng_mustDeliverQuestionary;
  iamimg.onload = iam_ng_deactivateClient;
}

function iam_ng_getRootDomain() {
  if(window.location.hostname.search(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/) != -1) {
    return window.location.hostname;
  } else {
    var iam_ng_domain_reverse = window.location.hostname.split(".").reverse();
    var iam_ng_element1 = iam_ng_domain_reverse.shift();
    var iam_ng_element2 = iam_ng_domain_reverse.shift();
    return iam_ng_element2 + "." + iam_ng_element1;
  }
}

function iam_ng_deactivateClient() {
  var iam_ng_div = document.getElementById("szm_divlayer_ng");
  if(iam_ng_div != null) iam_ng_div.style.display = "none";
  var szmexp = new Date();
  var szmnex = szmexp.getTime() + iam_ng_recheckIntervall;
  szmexp.setTime(szmexp.getTime() + (1000*60*60*24*365*10) );
  document.cookie = "POPUPCHECK=" +szmnex+ "; expires="+szmexp.toGMTString()+"; path=/; domain="+iam_ng_getRootDomain()+";";
}

function iam_ng_mustDeliverQuestionary() {
  var imgserver = new Image();
  imgserver.src = iam_ng_host+iam_ng_resolveQSGIF+"?szmvar="+szmvars+"&wmid="+iam_ng_ValidWMID+"&ver="+iam_ng_Vers;
  imgserver.onload = iam_ng_Analyser;
  imgserver.onerror = iam_ng_CatchError;
}

function iam_ng_nxss() {
  if(iam_ng_isActive()) {
    iam_ng_isClientSampleMember(iam_ng_host);
    return;
  }
}

function iam_ng_Analyser(iam_ng_evt) {
  var ir_time = new Date();
  var ir_randmulti = Math.random();
  var ir_random = Math.ceil(ir_time.getTime()*ir_randmulti);
  var ir_lock = new Image();
  ir_lock.src = iam_ng_host+"/do/nextcheck.gif?delta=315360000000&z="+ir_random;

  var irimg = new Image();
  irimg.src = iam_ng_host + iam_ng_invitationGIF+"?szmvar="+szmvars+"&posx=0&posy=0&vis="+iam_ng_vis+"&fade="+iam_ng_fadeout+"&wmid="+iam_ng_ValidWMID+"&ver="+iam_ng_Vers+"&ex=0";

  if(iam_ng_fadeout_flash) {
      setTimeout("iam_ng_disable_errors('EMBED')",1000);
      setTimeout("iam_ng_disable_errors('OBJECT')",1000);
      iam_ng_rm_2 = setInterval("iam_ng_disable_errors('EMBED')",3000);
      iam_ng_rm_1 = setInterval("iam_ng_disable_errors('OBJECT')",3000);
  }
  if(iam_ng_fadeout_iframe) {
      setTimeout("iam_ng_disable_errors('IFRAME')",1000);
      iam_ng_rm_3 = setInterval("iam_ng_disable_errors('IFRAME')",3000);
  }
  if(iam_ng_fadeout_form) {
      setTimeout("iam_ng_disable_errors('SELECT')",1000);
      setTimeout("iam_ng_disable_errors('OPTION')",1000);
      iam_ng_rm_4 = setInterval("iam_ng_disable_errors('SELECT')",3000);
      iam_ng_rm_5 = setInterval("iam_ng_disable_errors('OPTION')",3000);
  }
  window.setTimeout(function () {
    InsertLayer();
  }, 100);



}

function iam_ng_CP4(iam_ng_cl) {
  var cpimg = new Image();
  cpimg.src = iam_ng_host + iam_ng_closeGIF +"?szmvar="+szmvars+"&wmid="+iam_ng_ValidWMID+"&ver="+iam_ng_Vers+"&cl="+iam_ng_cl;
  window.setTimeout('iam_ng_close()', 200);
}

function iam_ng_optout(iam_ng_wmt) {
  var opimg = new Image();
  opimg.src = iam_ng_host + iam_ng_optoutGIF +"?szmvar="+szmvars+"&wmid="+iam_ng_ValidWMID+"&ver="+iam_ng_Vers+"&wmt="+iam_ng_wmt;
  var stimg = new Image();
  stimg.src = iam_ng_host+"/sticky/";
  document.getElementById("iam_ng_optout_image").src = iam_ng_mediapath+"tick_active.gif";
  window.setTimeout('iam_ng_close()', 1000);
}
function iam_ng_later(iam_ng_wmt) {
  var laimg = new Image();
  laimg.src = iam_ng_host + iam_ng_laterGIF +"?szmvar="+szmvars+"&wmid="+iam_ng_ValidWMID+"&ver="+iam_ng_Vers+"&wmt="+iam_ng_wmt+"&later=1";
  window.setTimeout('iam_ng_close()', 200);
}

function iam_ng_CatchError() {
  var iam_ng_CatchError = 1;
}



function iam_ng_close(evt) {
  document.getElementById("szm_divlayer_ng").style.display = "none";
  if(iam_ng_fadeout_flash) {
      window.clearInterval(iam_ng_rm_1);
      window.clearInterval(iam_ng_rm_2);
      iam_ng_activate_invisible("OBJECT");
      iam_ng_activate_invisible("EMBED");
  }
  if(iam_ng_fadeout_iframe) {
      window.clearInterval(iam_ng_rm_3);
      iam_ng_activate_invisible("IFRAME");
  }
  if(iam_ng_fadeout_form) {
      window.clearInterval(iam_ng_rm_4);
      window.clearInterval(iam_ng_rm_5);
      iam_ng_activate_invisible("SELECT");
      iam_ng_activate_invisible("OPTION");
  }
}

function iam_ng_close_and_participate() {
  window.open(iam_ng_host+iam_ng_openPopup+'?szmvar='+szmvars+'&amp;wmid='+iam_ng_ValidWMID+'&amp;ver='+iam_ng_Vers+'&amp;wm='+iam_ng_wm);
  iam_ng_close();
}

function iam_ng_show_DS(){
  window.open("http://www.agof.de/index.879.de.html");
}

function iam_ng_CalcWMID() {
  var ActTime = new Date();
  var RandMulti = Math.random();
  var WMID = Math.ceil(ActTime.getTime()*RandMulti);
  return WMID;
}

  function iam_ng_relative_position() {
    if (window.document.documentElement.scrollTop > window.document.body.scrollTop) {
      iam_ng_scroll_top = window.document.documentElement.scrollTop;
    } else {
      iam_ng_scroll_top = window.document.body.scrollTop;
    }
    if (window.document.documentElement.scrollLeft > window.document.body.scrollLeft) {
      iam_ng_scroll_left = window.document.documentElement.scrollLeft;
    } else {
      iam_ng_scroll_left = window.document.body.scrollLeft;
    }
    document.getElementById("szm_divlayer_ng").style.left = iam_ng_scroll_left + iam_ng_position_left + "px";
    document.getElementById("szm_divlayer_ng").style.top =  iam_ng_scroll_top + iam_ng_position_top + "px";
  }

  function iam_ng_disable_errors(iam_ng_trg) {
    var iam_ng_sel = document.getElementsByTagName(iam_ng_trg);
    for (var i=0;i<iam_ng_sel.length;i++) {
      if (iam_ng_trg == "IFRAME") {
        if (iam_ng_sel[i].src.split('/')[2] == undefined || iam_ng_sel[i].src.split('/')[2] == window.location.hostname) {
          var iam_ng_iframe_object = iam_ng_sel[i].contentWindow.frames.document.getElementsByTagName("OBJECT");
          for (var j=0;j<iam_ng_iframe_object.length;j++) {
            if (iam_ng_iframe_object[j].style.visibility != "hidden") {
              iam_ng_iframe_object[j].style.visibility = 'hidden';
            }
          }
          var iam_ng_iframe_embed = iam_ng_sel[i].contentWindow.frames.document.getElementsByTagName("EMBED");
          for (var j=0;j<iam_ng_iframe_embed.length;j++) {
            if (iam_ng_iframe_embed[j].style.visibility != "hidden") {
              iam_ng_iframe_embed[j].style.visibility = "hidden";
            }
          }
        } else {
          if (iam_ng_sel[i].style.visibility != "hidden") {
            iam_ng_sel[i].style.visibility = "hidden";
          }
        }
      } else {
        if (iam_ng_sel[i].style.visibility != "hidden") {
          iam_ng_sel[i].style.visibility = "hidden";
        }
      }
    }
  }

  function iam_ng_activate_invisible(iam_ng_trg) {
    var iam_ng_sel = document.getElementsByTagName(iam_ng_trg);
    for (var i=0;i<iam_ng_sel.length;i++) {
      if (iam_ng_trg == "IFRAME") {
        if (iam_ng_sel[i].src.split('/')[2] == undefined || iam_ng_sel[i].src.split('/')[2] == window.location.hostname) {
          var iam_ng_iframe_embed = iam_ng_sel[i].contentWindow.frames.document.getElementsByTagName("EMBED") || iam_ng_sel[i].contentDocument.frames.document.getElementsByTagName("EMBED");
          for (var j=0;j<iam_ng_iframe_embed.length;j++) {
            iam_ng_iframe_embed[j].style.visibility = "visible";
          }
          var iam_ng_iframe_object = iam_ng_sel[i].contentWindow.frames.document.getElementsByTagName("OBJECT") || iam_ng_sel[i].contentDocument.frames.document.getElementsByTagName("OBJECT");
          for (var j=0;j<iam_ng_iframe_object.length;j++) {
            iam_ng_iframe_object[j].style.visibility = "visible";
          }
        } else {
          iam_ng_sel[i].style.visibility = "visible";
        }
      } else {
        iam_ng_sel[i].style.visibility = "visible";
      }
    }
  }

  iam_layer = '<style>div.iam_ng_button_de:hover { background-image:url('+iam_ng_mediapath+'btn_participate-now_hover.gif);}</style><style> div.iam_ng_button_de_later:hover { background-image:url('+iam_ng_mediapath+'btn_participate-later_hover.gif);} .iam_ng_hover {cursor:pointer;}</style>'+
  '<div id="szm_divlayer_ng" style="overflow:visible;position:absolute;left:0px;top:0px;border:none;z-index:'+iam_ng_zindex+';background:none;width:670px;height:420px;">'+
  '<div id="szm_layer" style="overflow:visible;z-index:'+iam_ng_zindex+';position:absolute;top:0px;left:0px;width:670px;height:420px;background-image:url('+iam_ng_mediapath+'layer.gif);background-repeat:no-repeat">'+
  '<img src="'+iam_ng_mediapath+'transparent.gif" alt="" onclick="iam_ng_CP4(0);" width="61" height="8" style="position:absolute;left:583px;top:21px;cursor:pointer;" border="0" />'+
  '<div class="iam_ng_button_de iam_ng_hover" style="padding:0px;margin:0;position:absolute;left:262px;top:271px;display:block;background-image:url('+iam_ng_mediapath+'transparent.gif);width:162px;height:34px;cursor:pointer;" onclick="iam_ng_close_and_participate();">'+
  '  <img src="'+iam_ng_mediapath+'transparent.gif" alt=""  width="162" height="34" border="0" />'+
  '</div>'+
  '<div class="iam_ng_hover" style="position:absolute;left:373px;top:352px;width:40px;height:10px;cursor:pointer;" onclick="iam_ng_show_DS();">'+
  '  <img src="'+iam_ng_mediapath+'transparent.gif" alt="" width="40" height="10" border="0"  />'+
  '</div>'+
  '<div class="iam_ng_hover" href="javascript:return false;" onclick="iam_ng_close_and_participate();" alt="" style="position:absolute;left:44px;top:43px;cursor:pointer;width:134px;height:50px;">'+
  '  <img src="'+SITELOGO_NG+'"  border="0" width="134" height="50" />'+
  '</div>'+
  '<div class="iam_ng_hover" href="javascript:return false;" onclick="iam_ng_close_and_participate();" style="padding:0px;margin:0;position:absolute;left:547px;top:317px;width:70px;height:65px;cursor:pointer;">'+
  '  <img src="'+iam_ng_mediapath+'transparent.gif"  alt="" width="70" height="65" border="0" />'+
  '</div>'+
  '<div class="iam_ng_button_de_later iam_ng_hover" onclick="iam_ng_later(0);" style="padding:0px;margin:0;position:absolute;left:77px;top:271px;display:block;background-image:url('+iam_ng_mediapath+'transparent.gif);width:162px;height:34px;cursor:pointer;">'+
  '  <img src="'+iam_ng_mediapath+'transparent.gif" alt=""  width="162" height="34" border="0" />'+
  '</div>'+
  '<img id="iam_ng_optout_image" class="iam_ng_hover" src="'+iam_ng_mediapath+'transparent.gif" alt="" onclick="iam_ng_optout(0);" width="11" height="11" style="position:absolute;left:172px;top:388px;cursor:pointer;" border="0" />'+
  '</div>'+
  '</div>';

  var iam_safeframeFunctions = ''+
  '<scr'+'ipt>'+
  'var iam_ng_ValidWMID = '+iam_ng_ValidWMID+';'+
  'var iam_ng_Vers = '+iam_ng_Vers+';</scr'+'ipt>'+
  '<scr'+'ipt>'+
  '  function iam_ng_CP4(){'+
  '    var cpimg=new Image();'+
  '    cpimg.src="'+iam_ng_host+iam_ng_closeGIF+'?szmvar='+szmvars+'&wmid='+iam_ng_ValidWMID+'&ver='+iam_ng_Vers+'&cl=0";'+
  '    window.setTimeout("iam_ng_close()",200)'+
  '  }'+
  '  function iam_ng_optout(){'+
  '    var opimg=new Image();'+
  '    opimg.src="'+iam_ng_host+iam_ng_optoutGIF+'?szmvar='+szmvars+'&wmid='+iam_ng_ValidWMID+'&ver='+iam_ng_Vers+'&wmt=";'+
  '    var stimg=new Image();'+
  '    stimg.src="'+iam_ng_host+'/sticky/";'+
  '    document.getElementById("iam_ng_optout_image").src="'+iam_ng_mediapath+'tick_active.gif";'+
  '    window.setTimeout("iam_ng_close()",1000)'+
  '  }'+
  '  function iam_ng_later(){'+
  '    var laimg=new Image();'+
  '    laimg.src="'+iam_ng_host+iam_ng_laterGIF+'?szmvar='+szmvars+'&wmid='+iam_ng_ValidWMID+'&ver='+iam_ng_Vers+'&wmt=1&later=1";'+
  '    window.setTimeout("iam_ng_close()",200)'+
  '  }'+
  '  function iam_ng_close(){'+
  '    document.getElementById("szm_divlayer_ng").style.display="none";'+
  '    Y.SandBox.vendor.lyr.close()'+
  '  }'+
  '  function iam_ng_close_and_participate(){'+
  '    document.getElementById("szm_divlayer_ng").style.display="none";'+
  '    window.open("'+iam_ng_host+iam_ng_openPopup+'?szmvar='+szmvars+'&amp;wmid='+iam_ng_ValidWMID+'&amp;ver='+iam_ng_Vers+'&amp;wm='+iam_ng_wm+'");'+
  '    Y.SandBox.vendor.lyr.close()'+
  '  }'+
  '  function iam_ng_show_DS(){window.open("http://www.agof.de/index.879.de.html");}'+
  '</scr'+'ipt>';



  var InsertLayer = function() {
    if(useYAPI) {
      var iam_lyr_position = {
        w: expandedWidth,
        h: expandedHeight,
        html: iam_safeframeFunctions + iam_layer,
        fixed: 1,
        center: 'both'
      };
      Y.SandBox.vendor.lyr.open(iam_lyr_position);
    } else {
      var layerTarget = document.getElementById('iam');
      layerTarget.innerHTML = iam_layer;
      iam_ng_relative_position();
    }

  };

