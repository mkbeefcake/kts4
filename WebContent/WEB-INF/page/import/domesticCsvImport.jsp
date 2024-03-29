<?xml version="1.0" encoding="UTF-8""?>
<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html:html>
	<head>
	<jsp:include page="/WEB-INF/page/define/define-meta.jsp" />
	<link rel="stylesheet" href="./css/import.css" type="text/css" />
	<script src="./js/jquery-1.10.2.min.js" language="javascript"></script>

<!--
【受注データ取込画面】
ファイル名：domesticCsvImport.jsp
作成日：2017/1/9
作成者：boncre

（画面概要）

助ネコのCSV(国内注文データ)を取り込む画面。
送り状番号は付与されていないのが前提。

・CSV選択ボタン押下：助ネコのCSVを選択する。

・インポートボタン押下：引っ張ってきたCSVファイルを売上データとして取り込む

【画面上部】
プルダウンにて選択された法人を付与し、1つのみ取込可能

【画面下部】
ファイル名から法人を判別し、5つまで同時に取り込む

（注意・補足）

-->

	<script>
	$(document).ready(function(){
		$(".overlay").css("display", "none");
		var errStr = "";
		$("#errorArea").children("p").each(function() {
			errStr = errStr + $(this).html() + "\n";
		});
		if (errStr != '') {
			alert(errStr);
			$('#errorArea').hide();
		}
	 });
$(function () {

	//メッセージエリア表示設定
	if(!$("#registryDto.message").val()) {
		if($("#messageFlg").val() == "0") {
			$("#messageArea").addClass("registrySuccess");
		}
		if($("#messageFlg").val() == "1"){
			$("#messageArea").addClass("registryFailure");
		}
		$("#messageArea").fadeOut(4000);
	}

	$(".importButton").click(function () {

		if ($("#filupload_01").val() == "" || $("#select_box").val() == "0") {

			alert("法人とファイルを選択してください。");
			return;
		}

		$(".overlay").css("display", "block");

		goTransaction("domesticCsvImport.do");
	});

	$(".listImportButton").click(function () {


		var i = 0;
		var j = 0;

		//少し長いけど、、、
		//インポートボタンを押せない条件

		//すべて空の場合
		if ($("#txtfilenameList_"+ i++).val() == "" && $("#txtfilenameList_"+ i++).val() == ""
					&& $("#txtfilenameList_"+ i++).val() == "" && $("#txtfilenameList_"+ i++).val() == ""
						&& $("#txtfilenameList_"+ i++).val() == "") {

			alert("ファイルを選択してください。");
			return;
		}

		//同ファイル名が一つでも存在する場合
		for (i = 0; i < $(".txtfilenameList").length; i++) {
			if ($("#txtfilenameList_"+ i).val() == "") {
				continue;
			}
			for (j = i + 1; j < $(".txtfilenameList").length; j++) {

				if ($("#txtfilenameList_"+ i).val() == $("#txtfilenameList_"+ j).val()) {
					alert("同一のファイルが選択されています。");
					return;
				}
			}
		}

		$(".overlay").css("display", "block");

		goTransaction("csvDomesticListImport.do");
	});

});

function filupload_01click() {

	document.getElementById("filupload_01").click();
}
	</script>
	</head>
	<jsp:include page="/WEB-INF/page/common/menu.jsp" />
	<html:form action="/initDomesticCsvImport" enctype="multipart/form-data">

		<nested:nest property="registryDto">
			<nested:hidden property="messageFlg" styleId="messageFlg"/>
			<nested:notEmpty property="message">
				<div id="messageArea">
					<p class="registryMessage" style="text-align: leght;"><nested:write property="message"/></p>
				</div>
			</nested:notEmpty>
		</nested:nest>

	<html:hidden property="alertType" styleId="alertType"/>
	<html:hidden property="trueCount" styleId="trueCount"/>

	<h4 class="heading">国内注文データ取込</h4>


	<div id="errorArea">
		<nested:nest property="csvErrorDTO">
			<nested:notEmpty property="fileName">
				<p class="fileName"><nested:write property="fileName"/></p>
			<br/>
			</nested:notEmpty>
			<nested:notEmpty property="errorMessageList">
				<nested:iterate property="errorMessageList">
					<p class="errorMessage"><nested:write property="errorMessage"/></p>
				</nested:iterate>
			</nested:notEmpty>
		</nested:nest>

		<nested:notEmpty property="csvErrorList">
			<nested:iterate property="csvErrorList">
				<nested:notEmpty property="fileName">
					<p class="fileName"><nested:write property="fileName"/></p>
				<br/>
				</nested:notEmpty>
				<nested:notEmpty property="errorMessageList">
					<nested:iterate property="errorMessageList">
						<p class="errorMessage"><nested:write property="errorMessage"/></p>
					</nested:iterate>
				</nested:notEmpty>
			</nested:iterate>
		</nested:notEmpty>
	</div>


	<div id="import_div">


		<p class="import_message">※助ネコのフォーマット以外のCSVは取り込まないようにしてください。</p>
			<p class="import_message">(システムエラーになる可能性があります。)</p>
		<br/>
			<p class="import_elements"><nested:select property="corporationId" styleId="select_box">
			<html:option value="0">　　　　　法人を選択してください　　　　　</html:option>
							<nested:optionsCollection property="corporationList" label="corporationNm" value="sysCorporationId" />
							</nested:select></p>
			<p class="import_elements">
			<nested:file property="fileUp" styleId="filupload_01" styleClass="dn" onchange="txtfilename_01.value = this.value;"/>
				<input type="text" id="txtfilename_01" class="input_fileupload"  size="25" disabled="disabled"/>
				<input type="button" id="btnbrowse_01" class="btn_fileupload_green" onmouseover="this.className='btn_fileupload_over_green'" onmouseout="this.className='btn_fileupload_green'" onclick="filupload_01.click()" value=""/>
			</p>
			<div class="buttonPositionTop">
				<input type="button" class="btn_import_green importButton" onmouseover="this.className='btn_import_over_green'" onmouseout="this.className='btn_import_green'"/>
			</div>


			<h3 class="multi_import">一括取り込み</h3>
			<p class="import_message">※「OS_【法人名半角英数字】_【日付】.csv」このファイル名以外のものは取り込まないようにしてください。</p>
			<br/>

			<nested:iterate property="csvInputList" indexId="idx">
				<p class="import_elements">
					<nested:file property="fileUp" styleId="filuploadList_${idx}" styleClass="dn" onchange="txtfilenameList_${idx}.value = this.value;"/>
					<input type="text" id="txtfilenameList_${idx}" name="csvInputList${idx}.csvFileName" class="input_fileupload txtfilenameList" size="25" disabled="disabled" />
					<input type="button" id="btnbrowseList_${idx}" class="btn_fileupload_green" onmouseover="this.className='btn_fileupload_over_green'"
							onmouseout="this.className='btn_fileupload_green'" onclick="filuploadList_${idx}.click()" value=""/>
				</p>
			</nested:iterate>

		<br/>
		<div class="buttonPositionBottom">

			<input type="button" class="btn_import_green listImportButton" onmouseover="this.className='btn_import_over_green'" onmouseout="this.className='btn_import_green'"/>

		</div>
	</div>
	</html:form>

	<div class="overlay">
		<div class="messeage_box">
			<h1>インポート中</h1>
			<BR />
			<p>Now Loading...</p>
			<img  src="./img/load.gif" alt="loading" ></img>
				<BR />
				<BR />
				<BR />
		</div>
	</div>
</html:html>