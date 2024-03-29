<?xml version="1.0" encoding="UTF-8""?>
<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html:html>
	<head>
	<jsp:include page="/WEB-INF/page/define/define-meta.jsp" />
	<link rel="stylesheet" href="./css/itemDetail.css" type="text/css" />
	<link rel="stylesheet" href="./css/jquery-ui-1.10.4.custom.min.css" type="text/css" />
	<link rel="stylesheet" href="./css/jquery-ui-1.10.4.custom.css" type="text/css" />
	<script src="./js/jquery-1.10.2.min.js" language="javascript"></script>
	<script src="./js/jquery-ui-1.10.4.custom.min.js" language="javascript"></script>

	<script src="./js/jquery.ui.core.min.js"></script>
	<script src="./js/jquery.ui.datepicker.min.js"></script>
	<script src="./js/jquery.ui.datepicker-ja.min.js"></script>

	<script src="./js/fw.js" type="text/javascript" type="text/javascript"></script>
	<script src="./js/validation.js" type="text/javascript"></script>

<!--
【商品詳細画面】
ファイル名：itemDetail.jsp
作成日：2014/12/29
作成者：八鍬寛之

（画面概要）

商品マスタの新規登録・詳細画面
詳細画面は在庫一覧から遷移
※「分類」の項目は現在使用していない

【基本情報エリア】
・総在庫数の隣のカッコは仮在庫数。キープをかける毎に総在庫数からマイナスされる。
・どの倉庫に何個在庫があるか登録でき、その合計が総在庫数となる。
・倉庫の優先度はこの画面以外で在庫の増減を行う場合、優先度の高い倉庫を対象とするため。

以下画面右半分の各タブの概要

【キープ】
・受注番号と個数を入れて登録すると個数分が総在庫数からマイナスされる。
・出庫時にここで登録した受注番号のものを出庫した場合は対象のキープのデータが消える。

【入荷予定】
・入荷予定情報を複数登録できる。「曖昧予定日」には「10末」等のメモが入る。
・「入荷数分入荷」ボタン押下：入荷予定数の数が優先度1の倉庫にプラスされ、その行のデータが入荷履歴のタブに入る。
　　もし全ての入荷予定数が入荷されたらその行は消え、残数があると残る。(修正ボタンを押さないと反映されない)

【入荷履歴】
・入荷予定タブで「入荷数分入荷」されたデータが入る。一括入荷画面でも同様。

【価格情報】
・法人マスタにある各法人毎に原価/売価を設定できる。
・「1列目をコピー」リンク押下：一番上の法人の原価/売価を全ての法人にコピーする。

【BO】
・キープ機能が実装されてから使用されていない

【説明書】
・JPEG/PDFファイルのアップロードが5つまで可能。

（注意・補足）

-->


<script type="text/javascript">

	function PxTextareaAdjuster(textarea){
		textarea.style.overflow='hidden';
		textarea.style.height = 13 +'px';
		if( textarea.scrollHeight  > textarea.offsetHeight ){
			textarea.style.height = textarea.scrollHeight -2 +'px';
	    }
	}

$(function () {

	var count = $('.indexNum').length;

	$('.num').spinner( {
		max: 9999,
		min: 0,
		step: 1
	});

	$(".calender").datepicker();
	$(".calender").datepicker("option", "showOn", 'button');
	$(".calender").datepicker("option", "buttonImageOnly", true);
	$(".calender").datepicker("option", "buttonImage", './img/calender_icon.png');

	if ($('#sysSupplierId').val() != 0) {
		var strSupplierId = String($('#sysSupplierId').val());
		$('#supplierId').val(strSupplierId);
	}

	$('#rightArea > ul > li').click(function () {
		$('#rightArea > div').hide().filter($(this).find('a').attr('href')).show();

		$('#rightArea > ul > li').removeClass('active');
		$(this).addClass('active');

		return false;
	}).filter(':eq(0)').click();

	//■onload時
	seltab('box', 'head', 4, 1);


	//追加時のタグ操作用変数
	var tr = "";
	var aTag = "";

	//倉庫在庫追加部分を隠す
	var addWarehouseTrs = $("tr.addWarehouseStockRow");
	addWarehouseTrs.hide();
	var addWarehouseIdx = 0;

	//まだ登録されていない倉庫がある場合倉庫在庫追加を表示
	if ($(".warehouseNum").length < $("#warehouseLength").val()) {

		//一行分
		tr = addWarehouseTrs.eq(addWarehouseIdx);

		//商品登録画面か商品詳細画面の判定
		//商品登録画面の場合追加ボタンは表示しないため
		if ($("#newItemregistry").val() != 0) {
			// aタグの操作
			aTag = tr.find(".button_small_white");
			if (aTag) {
				aTag.attr("class", "button_small_main addWarehouse");
				aTag.text("追加");
			}
		}
		tr.show();
		addWarehouseTrs = "";
		tr = "";
		aTag = "";

		appendPrioritySelect();
	}

	//商品登録画面か商品詳細画面の判定
	if ($("#newItemregistry").val() == 0) {

		while (addWarehouseIdx + 1 < $("#warehouseLength").val()) {

			//一行分表示
 			var trs = $("tr.addWarehouseStockRow");
			var tr = trs.eq(++addWarehouseIdx);
			tr.show();

			var length = $(".warehouseNum").length + addWarehouseIdx + 1;
			$(".prioritySelect").append($('<option>').html(length).val(length));
		}

		//商品登録画面では削除ボタンを表示しない
		$(".wTdButton").hide();
		addValueWarehouse();
	}

// 	//入荷予定追加
// 	var addArrivalSceduleTrs = $("tr.addArrivalScheduleRow");
// 	addArrivalSceduleTrs.hide();
// // 	var addArrivalScheduleIdx = $("#addArrivalScheduleLength").val() -1;
// 	var addArrivalScheduleIdx = 0;
// 	tr = addArrivalSceduleTrs.eq(addArrivalScheduleIdx);

// 	// aタグの操作
// 	aTag = tr.find(".button_small_white");
// 	if (aTag) {
// 		aTag.attr("class", "button_small_main addArrivalScheduleDate");
// 		aTag.text("追加");
// 	}
// 	tr.show();
// 	tr = "";
// 	aTag = "";

	//バックオーダー追加
	var addBackOrderRowTbody = $(".addBackOrderTbody");
	addBackOrderRowTbody.hide();

	var addBackOrderIdx = 0;
	tbody = addBackOrderRowTbody.eq(addBackOrderIdx);

	// aタグの操作
	aTag = tbody.find("a");
	if (aTag) {
		aTag.attr("class", "button_small_main addBackOrder");
		aTag.text("追加");
	}
	tbody.show();
	tbody = "";
	aTag = "";

	//不良在庫追加
	var addDeadStockRow = $(".addDeadStockRow");
	addDeadStockRow.hide();

	var addDeadStockIdx = 0;
	var deadStockTr = addDeadStockRow.eq(addDeadStockIdx);

	// aタグの操作
	aTag = deadStockTr.find(".button_small_white");
	if (aTag) {
		aTag.attr("class", "button_small_main addDeadStock");
		aTag.text("追加");
	}
	deadStockTr.show();

	deadStockTr = "";
	aTag = "";

	//キープ追加
	var addKeepRow = $(".addKeepRow");
	addKeepRow.hide();

	var addKeepIdx = 0;
	keepTr = addKeepRow.eq(addKeepIdx);

	// aタグの操作
	aTag = keepTr.find(".button_small_white");
	if (aTag) {
		aTag.attr("class", "button_small_main addKeep");
		aTag.text("追加");
	}
	keepTr.show();

	keepTr = "";
	aTag = "";


	//外部倉庫キープ追加
	var addExternalKeepRow = $(".addExternalKeepRow");
	addExternalKeepRow.hide();

	var addExternalKeepIdx = 0;
	externalKeepTr = addExternalKeepRow.eq(addExternalKeepIdx);

	// aタグの操作
	aTag = externalKeepTr.find(".button_small_white");
	if (aTag) {
		aTag.attr("class", "button_small_main addExternalKeep");
		aTag.text("追加");
	}
	externalKeepTr.show();

	externalKeepTr = "";
	aTag = "";


	//説明書
	var itemManualRows = $(".itemManualRow");
	var itemManualIdx = new Number(0);
	tr = itemManualRows.eq(itemManualIdx);
	tr.show();
	tr = "";
	var addItemManualRows = $(".addItemManualRow");
	//addItemManualRows.hide();

	var addItemManualIdx = new Number(0);
	tr = addItemManualRows.eq(addItemManualIdx);
	aTag = tr.find("a");
	tr.show();
	tr = "";
	aTag = "";

	//アラート
	if (document.getElementById('alertType').value != '' && document.getElementById('alertType').value != '0') {
		if ($("#alertType").val() == 1 && window.opener) {
			window.close();
		}
		document.getElementById('alertType').value = '0';
	}


	//入力フォーム初期値の0を消す処理
	$(".numText").focus (function() {

		var num = $(this).val();
		if (num == 0) {
			$(this).val('');
		} else {
			num.toString().replace(/,/g , "");
			$(this).val(num);
		}
	})
	.blur (function () {

		var num = $(this).val();

		if (num == '') {
			$(this).val(0);
		} else {
			num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
			$(this).val(num);
		}
	});


	//■イベントハンドラ系function

	//倉庫在庫行追加
	//追加ボタンからみて一つ下の行に倉庫在庫入力項目を追加させる。（表示させる）
	//倉庫は優先順位があり、優先順位順に入力していく仕様なので画面上の他の二つ(入荷予定・バックオーダー)追加機能とは異なる。
	$(".addWarehouse").click(function () {

		if ($(".warehouseNum").length + addWarehouseIdx + 1 >= $("#warehouseLength").val()) {
			alert("倉庫はこれ以上存在しません。");
			return;
		}
		//一行分表示
		var trs = $("tr.addWarehouseStockRow");
		var tr = trs.eq(++addWarehouseIdx);
		tr.show();
		appendPrioritySelect();
		$('input[name="addWarehouseStockList['+ addWarehouseIdx +']stockNum"]').val(0);
		$('select[name="addWarehouseStockList['+ addWarehouseIdx +']sysWarehouseId"]').val("");
	});

	//倉庫在庫行削除
	$(".removeWarehouse").click(function () {

		var trs = $("tr.addWarehouseStockRow");
		var i = 0;
		for (i = $("tr.addWarehouseStockRow").index($(this).parents("tr.addWarehouseStockRow")); i <= addWarehouseIdx; i++) {

			var copyFromTr = trs.eq(i + 1);
			var copyToTr = trs.eq(i);

			copyToTr.find(".priority").val(copyFromTr.find(".priority").val());
			copyToTr.find(".sysWarehouseId").val(copyFromTr.find(".sysWarehouseId").val());
			copyToTr.find(".stockNum").val(copyFromTr.find(".stockNum").val());
			copyToTr.find(".locationNo").val(copyFromTr.find(".locationNo").val());

			copyFromTr.find(".priority").val(0);
			copyFromTr.find(".sysWarehouseId").val(0);
			copyFromTr.find(".stockNum").val(0);
			copyFromTr.find(".locationNo").val("");
		}

		$("select.prioritySelect option:last-child").remove();
		var tr = trs.eq(addWarehouseIdx--);
		tr.hide();
	});

	//入荷完了
	$(".sceduleDateCompleteButton").click(function () {

		if ($(this).parents("tr").find(".arrivalFlag").val() == "1") {
			alert("もう一度入荷したい場合は修正ボタンを押してください");
			return;
		}

		var targetObj = null;
// 		var targetWarehouseNm = null;
		$(".prioritySelect").each(function (){

			if ($(this).children(":selected").val() == "1" && targetObj != null) {
				alert("優先度１の倉庫が複数あります");
				return;
			}

			if ($(this).children(":selected").val() == "1") {

// 				$("input:radio[name='deliveryRadio']:checked").val();
// 				alert("優先度１");

				targetObj = $(this).parents("tr").find(".num");
// 				targetWarehouseNm = $(this).parents("tr").find(".warehouseNm");
			}


		});

		if (!targetObj || targetObj == null) {
			alert("優先度１の倉庫がありません");
			return;
		}

// 		alert(targetObj.val());
// 		alert($(this).parents("tr").find(".arrivalNum").val());

		//入荷フラグを立てる
		$(this).parents("tr").find(".arrivalFlag").val("1");

		var arrivalNum = new Number($(this).parents("tr").find(".arrivalNum").val());
		var arrivalScheduleNum = new Number($(this).parents("tr").find(".arrivalScheduleNum").val());


		//予定より多く入荷することは今できません。
// 		if (arrivalNum > arrivalScheduleNum) {

// 			$(this).parents("tr").find(".arrivalNum").val(arrivalScheduleNum);
// 			alert("予定より多く入荷できません");
// 			return;
// 		}
		alert("第一倉庫の在庫数を" + arrivalNum + "個増やします。");
		//第一倉庫に入荷分追加
		targetObj.val(Number(targetObj.val()) + arrivalNum);

		//入荷数が減らされた場合
		if (arrivalNum < arrivalScheduleNum) {

			arrivalScheduleNum -= arrivalNum;
			$(this).parents("tr").find(".arrivalNum").val(arrivalScheduleNum);
// 			$(this).parents("tr").find(".arrivalScheduleNum").val(arrivalScheduleNum);
			alert(arrivalNum + "個入荷したので、残り入荷数が" + arrivalScheduleNum + "になりました");
			return;
		}

		//入荷数に変更がない場合隠す。
		$(this).parents("tr").hide();
	});

	//入荷予定削除
	$(".sceduleDateDeleteButton").click(function () {

		if (!confirm("入荷予定を削除します、よろしいですか？？")) {
			return;
		}
		$(this).parents("tr").find(".deleteFlag").val("1");
		$(this).parents("tr").hide();
	});

	//バックオーダー追加
	$(".addBackOrder").click(function () {

		if (addBackOrderIdx + 1 >= $("#addBackOrderLength").val()) {
			alert("一括で登録できるのは5件までです。");
			return;
		}

		var tbodyList = $(".addBackOrderTbody");
		var i = 0;
		for (i = addBackOrderIdx; i >= 0; i--) {

			var copyFromTr = tbodyList.eq(i);
			var copyToTr = tbodyList.eq(i + 1);

			copyToTr.find(".remarks").val(copyFromTr.find(".remarks").val());
			copyToTr.find(".sysCorporationId").val(copyFromTr.find(".sysCorporationId").val());
			copyToTr.find(".sysChannelId").val(copyFromTr.find(".sysChannelId").val());

			copyFromTr.find(".remarks").val("");
			copyFromTr.find(".sysCorporationId").val(0);
			copyFromTr.find(".sysChannelId").val(0);
		}

		var tbody = tbodyList.eq(++addBackOrderIdx);
		tbody.show();
	});

	//バックオーダー削除
	$(".removeBackOrder").click(function () {

		var tbodyList = $(".addBackOrderTbody");
		var i = 0;
		for (i = $(".addBackOrderTbody").index($(this).parents(".addBackOrderTbody")); i <= addBackOrderIdx; i++) {

			var copyFromTr = tbodyList.eq(i + 1);
			var copyToTr = tbodyList.eq(i);

			copyToTr.find(".remarks").val(copyFromTr.find(".remarks").val());
			copyToTr.find(".sysCorporationId").val(copyFromTr.find(".sysCorporationId").val());
			copyToTr.find(".sysChannelId").val(copyFromTr.find(".sysChannelId").val());

			copyFromTr.find(".remarks").val("");
			copyFromTr.find(".sysCorporationId").val(0);
			copyFromTr.find(".sysChannelId").val(0);
		}

		var tbody = tbodyList.eq(addBackOrderIdx--);
		tbody.hide();
	});

	$(".completeBackOrder").click (function () {

		$(this).parents("tbody").find(".deleteFlag").val("1");
		$(this).parents("tbody").hide();

	});

	//仕入先IDを入力し、検索ボタン押下時の処理
	$("#searchSupplier").click (function () {

		var longSupplierId = $("#supplierId").val();
		Number(longSupplierId);
		$("#sysSupplierId").val(longSupplierId);

		$("#searchSysSupplierId").val($("#sysSupplierId").val());

		FwGlobal.submitForm(document.forms[0],"/subWinItemSupplierSearch","supplierSearchWindow","top=130,left=500,width=780px,height=520px,scrollbars=1;");
	});

	//キープ追加
	$(".addKeep").click(function () {

		if (addKeepIdx + 1 >= $("#addKeepLength").val()) {
			alert("一括で登録できるのは5件までです。");
			return;
		}

		var trList = $(".addKeepRow");
		var i = 0;
		for (i = addKeepIdx; i >= 0; i--) {

			var copyFromTr = trList.eq(i);
			var copyToTr = trList.eq(i + 1);

			copyToTr.find(".orderNo").val(copyFromTr.find(".orderNo").val());
			copyToTr.find(".keepNum").val(copyFromTr.find(".keepNum").val());
			copyToTr.find(".remarks").val(copyFromTr.find(".remarks").val());

			copyFromTr.find(".orderNo").val("");
			copyFromTr.find(".keepNum").val(0);
			copyFromTr.find(".remarks").val("");
		}

		var tr = trList.eq(++addKeepIdx);
		tr.show();
	});

	//外部倉庫キープ追加
	$(".addExternalKeep").click(function () {

		if (addExternalKeepIdx + 1 >= $("#addExternalKeepLength").val()) {
			alert("一括で登録できるのは5件までです。");
			return;
		}

		var trList = $(".addExternalKeepRow");
		var i = 0;
		for (i = addExternalKeepIdx; i >= 0; i--) {

			var copyFromTr = trList.eq(i);
			var copyToTr = trList.eq(i + 1);

			copyToTr.find(".orderNo").val(copyFromTr.find(".orderNo").val());
			copyToTr.find(".keepNum").val(copyFromTr.find(".keepNum").val());
			copyToTr.find(".remarks").val(copyFromTr.find(".remarks").val());

			copyFromTr.find(".orderNo").val("");
			copyFromTr.find(".keepNum").val(0);
			copyFromTr.find(".remarks").val("");
		}

		var tr = trList.eq(++addExternalKeepIdx);
		tr.show();
	});

	//キープ削除
	$(".removeKeep").click(function () {

		var trList = $(".addKeepRow");
		var i = 0;
		for (i = $(".addKeepRow").index($(this).parents(".addKeepRow")); i <= addKeepIdx; i++) {

			var copyFromTr = trList.eq(i + 1);
			var copyToTr = trList.eq(i);

			copyToTr.find(".orderNo").val(copyFromTr.find(".orderNo").val());
			copyToTr.find(".keepNum").val(copyFromTr.find(".keepNum").val());
			copyToTr.find(".remarks").val(copyFromTr.find(".remarks").val());

			copyFromTr.find(".orderNo").val("");
			copyFromTr.find(".keepNum").val(0);
			copyFromTr.find(".remarks").val("");
		}

		var tr = trList.eq(addKeepIdx--);
		tr.hide();
	});

	//外部倉庫キープ削除
	$(".removeExternalKeep").click(function () {

		var trList = $(".addExternalKeepRow");
		var i = 0;
		for (i = $(".addExternalKeepRow").index($(this).parents(".addExternalKeepRow")); i <= addExternalKeepIdx; i++) {

			var copyFromTr = trList.eq(i + 1);
			var copyToTr = trList.eq(i);

			copyToTr.find(".orderNo").val(copyFromTr.find(".orderNo").val());
			copyToTr.find(".keepNum").val(copyFromTr.find(".keepNum").val());
			copyToTr.find(".remarks").val(copyFromTr.find(".remarks").val());

			copyFromTr.find(".orderNo").val("");
			copyFromTr.find(".keepNum").val(0);
			copyFromTr.find(".remarks").val("");
		}

		var tr = trList.eq(addExternalKeepIdx--);
		tr.hide();
	});

	//不良在庫追加
	$(".addDeadStock").click(function () {

		if (addDeadStockIdx + 1 >= $("#addDeadStockLength").val()) {
			alert("一括で登録できるのは5件までです。");
			return;
		}

		var trList = $(".addDeadStockRow");
		var i = 0;
		for (i = addDeadStockIdx; i >= 0; i--) {

			var copyFromTr = trList.eq(i);
			var copyToTr = trList.eq(i + 1);

			copyToTr.find(".addDeadReason").val(copyFromTr.find(".addDeadReason").val());
			copyToTr.find(".addItemNum").val(copyFromTr.find(".addItemNum").val());

			copyFromTr.find(".addDeadReason").val("");
			copyFromTr.find(".addItemNum").val(0);
		}

		var tr = trList.eq(++addDeadStockIdx);
		tr.show();
	});

	//不良在庫削除
	$(".removeDeadStock").click(function () {

		var trList = $(".addDeadStockRow");
		var i = 0;
		for (i = $(".addDeadStockRow").index($(this).parents(".addDeadStockRow")); i <= addDeadStockRow.size(); i++) {

			var copyFromTr = trList.eq(i + 1);
			var copyToTr = trList.eq(i);

			copyToTr.find(".addDeadReason").val(copyFromTr.find(".addDeadReason").val());
			copyToTr.find(".addItemNum").val(copyFromTr.find(".addItemNum").val());

			copyFromTr.find(".addDeadReason").val("");
			copyFromTr.find(".addItemNum").val(0);
		}

		var tr = trList.eq(addDeadStockIdx--);
		tr.hide();
	});


// 	function buttonWhiteClick() {

// 		$(this).parents("tr").empty();
// 	}

	$(".priorityOptions").change(function () {

		priorityOptions();
	});

	$(".orderNumCheck").blur(function () {

		$(this).val($.trim($(this).val()));
	});

	//自動計算ボタン押下時処理
	$('.autoCalc').click(function () {
		var purchacePrice = 0;
		var kindCost = 0;
		var rate = $('#rate').val();
// 		var purchacePrice = $('#purchaceCost').val().replace(',','');
		var purchacePrice = removeComma($("#purchaceCost").val());
		purchacePrice = Math.round(purchacePrice * rate);

		//仕入価格に反映 ： 仕入金額 × レート
		$('#purchacePrice').val(purchacePrice);
		kindCost = purchacePrice + Number(removeComma($('#loading').val()));
		//Kind原価に反映： 仕入価格 + 加算経費
		$('#kindCost').val(kindCost);

		$('#cost0').val(Math.round(kindCost / 0.75));
		$('#cost1').val(Math.round(kindCost / 0.85));
		$('#cost2').val(Math.round(kindCost / 0.9));
		$('#cost3').val(Math.round(kindCost / 0.85));
		$('#cost4').val(Math.round(kindCost / 0.85));
		$('#cost5').val(Math.round(kindCost / 0.95));
		$('#cost6').val(Math.round(kindCost / 0.85));
		$('#cost7').val(Math.round(kindCost / 0.85));
		$('#cost8').val(Math.round(kindCost / 0.95));
		$('#cost9').val(Math.round(kindCost / 0.95));
		$('#cost10').val(Math.round(kindCost / 0.95));
		commmaAddFnc();

		if ($("#kindCost").val() != 0) {
			var cost = $("#kindCost")[0];
			addComma(cost);
		}

		if ($("#purchacePrice").val() != 0) {
			var purchacePrice = $("#purchacePrice")[0];
			addComma(purchacePrice);
		}
	});

	$('#reset').click(function () {

		$('#purchacePrice').val(0);
		$('#loading').val(0);
		$('#kindCost').val(0);

		$('#itemCost').each(function(){
		    $('.cost').val(0);
		});
	});

	//原価カンマ制御
	$(".cost").focus(function(){
		var index = $(".cost").index(this);
		if ($(".cost").eq(index).val() == 0) {
			$(".cost").eq(index).val("");
		} else {
			$(".cost").eq(index).val(removeComma($(".cost").eq(index).val()))
		}
	});
	$(".cost").blur(function(){
		var index = $(".cost").index(this);
		if ($(".cost").eq(index).val() == "") {
			$(".cost").eq(index).val(0);
		}
	});

	//売価カンマ制御
	$(".price").focus(function(){
		var index = $(".price").index(this);
		if ($(".price").eq(index).val() == 0) {
			$(".price").eq(index).val("");
		} else {
			$(".price").eq(index).val(removeComma($(".price").eq(index).val()))
		}
	});
	$(".price").blur(function(){
		var index = $(".price").index(this);
		if ($(".price").eq(index).val() == "") {
			$(".price").eq(index).val(0);
		}
	});

	//仕入価格カンマ制御
	$("#purchacePrice").focus(function(){
		if ($("#purchacePrice").val() == 0) {
			$("#purchacePrice").val("");
		} else {
			$("#purchacePrice").val(removeComma($("#purchacePrice").val()))
		}
	});
	$("#purchacePrice").blur(function(){
		if ($("#purchacePrice").val() == "") {
			$("#purchacePrice").val(0);
		}

		//仕入金額の桁数制御
		if (purchacePrice >= 10000000) {
			alert("仕入金額は7桁までです。");
			$('#purchacePrice').val(0.0)
			return false;
		}
	});

	//加算経費カンマ制御
	$("#loading").focus(function(){
		if ($("#loading").val() == 0) {
			$("#loading").val("");
		} else {
			$("#loading").val(removeComma($("#loading").val()))
		}
	});
	$("#loading").blur(function(){
		if ($("#loading").val() == "") {
			$("#loading").val(0);
		}
	});

	//Kind原価カンマ制御
	$("#kindCost").focus(function(){
		if ($("#kindCost").val() == 0) {
			$("#kindCost").val("");
		} else {
			$("#kindCost").val(removeComma($("#kindCost").val()))
		}
	});
	$("#kindCost").blur(function(){
		if ($("#kindCost").val() == "") {
			$("#kindCost").val(0);
		}
	});

	//海外閲覧権限を持っている場合下記処理実行
	if ($("#overseasInfoAuth").val() == "1") {
		//仕入金額のカンマを追加
		if ($("#purchaceCost").val() != "0.0") {
			var purchaceCost = $("#purchaceCost")[0];
			addComma(purchaceCost);
		}
		//仕入価格のカンマを追加
		if ($("#purchacePrice").val() != 0) {
			var purchacePrice = $("#purchacePrice")[0];
			addComma(purchacePrice);
		}
		//加算経費のカンマを追加
		if ($("#loading").val() != 0) {
			var loading = $("#loading")[0];
			addComma(loading);
		}
		//Kind原価のカンマを追加
		if ($("#kindCost").val() != 0) {
			var cost = $("#kindCost")[0];
			addComma(cost);
		}
	}

	commmaAddFnc();

	//登録
	$(".registry").click(function () {

		if($(".codeCheck").val() == "") {
			alert('品番を入力してください。');
			return;
		} else if($(".itemNmCheck").val() == "") {
			alert('商品名を入力してください。');
			return;
		}

		if ($(".codeCheck").val().replace(/\s+/g,'').length <= 10) {

			if ((!confirm("品番が10桁以下ですが、よろしいですか？"))) {
				return;
			}

		}

		//倉庫在庫追加登録判定
		if(!addWarehouseStockAlert($("tr.addWarehouseStockRow"))) {
			return;
		}

// 		if($(".codeCheck").val() == "") {
// 			alert('品番を入力してください。');
// 			return;
// 		}



		//BO追加登録判定
		if(!addBackOrderAlert($(".addBackOrderTbody"))) {
			return;
		}

		//資料追加登録判定
		if(!addDocumentAlert()) {
			return;
		}

		if (!confirm("登録します。よろしいですか？")) {
			return;
		}

		if ($("#overseasInfoAuth").val() == "1") {
			//仕入金額のカンマを外す
			if ($("#purchaceCost").val() != 0.0) {
				$("#purchaceCost").val(removeComma($("#purchaceCost").val()));
			}
		}

		var longSupplierId = $("#supplierId").val();
		Number(longSupplierId);
		$("#sysSupplierId").val(longSupplierId);

		$(".sysExternalWarehouseCode").val();

		removeCommaGoTransaction("registryItem.do");
	});

	//メッセージ表示設定
	if(!$('#registryMessageDTO.registryMessage').val()) {
		if($('#messageFlg').val() == "0") {
			$('#messageArea').addClass(" registrySuccess");
		}
		if($('#messageFlg').val() == "1"){
			$('#messageArea').addClass(" registryFailure");
		}
		$('#messageArea').fadeOut(4000);
	}

	//修正
	$(".update").click(function () {
		if ($(".codeCheck").val().replace(/\s+/g,'').length <= 10) {

			if ((!confirm("品番が10桁以下ですが、よろしいですか？"))) {
				return;
			}
		}

		//商品詳細画面倉庫修正判定
		if(!warehouseStockAlert($("tr.warehouseStockRow"), $("tr.addWarehouseStockRow"))) {
			return;
		}

// 		//入荷予定追加登録判定
// 		if(!addArrivalScheduleAlert($("tr.addArrivalScheduleRow"))) {
// 			return;
// 		}

		//バックオーダー追加判定
		if(!addBackOrderAlert($(".addBackOrderTbody"))) {
			return;
		}

		//登録済み資料修正判定
		if(!documentAlert()) {
			return;
		}

		//資料追加登録判定
		if(!addDocumentAlert()) {
			return;
		}


		////////////////不良在庫の入力不備チェック////////////////
		var typingErrorCnt = 0;
		$(".addDeadStockRow").each(function () {
			var addDetadReason = $(this).find(".addDeadReason").val();
			var addItemNum = $(this).find(".addItemNum").val();

			if ((addDetadReason == "" && addItemNum > 0)
					|| (addDetadReason != "" && addItemNum == 0)) {
				typingErrorCnt++;
			}
		})
		if (typingErrorCnt > 0) {
			if (!confirm("不良原因に入力不備があります。\n両方入力していない場合登録されません。")) {
				return;
			}
		}


		if (!confirm("更新します。よろしいですか？")) {
			return;
		}

		var longSupplierId = $("#supplierId").val();
		Number(longSupplierId);
		$("#sysSupplierId").val(longSupplierId);

		if ($("#overseasInfoAuth").val() == "1") {
			//仕入金額のカンマを外す
			if ($("#purchaceCost").val() != 0.0) {
				$("#purchaceCost").val(removeComma($("#purchaceCost").val()));
			}
		}

		removeCommaGoTransaction("updateItem.do");
	});

	//商品削除
	$("#delete").click (function () {

		if (confirm("商品を削除します。よろしいですか？")) {
			removeCommaGoTransaction("deleteItem.do");
		}
		return;
	});

	//分類検索
	$(".searchGroup").click(function () {

	});

	//説明書追加
	$(".addItemManual").click (function () {

		if (addItemManualIdx + 1 >= $("#addItemManualLength").val()) {
			alert("一括で登録できるのは"+ $("#addItemManualLength").val() +"件までです。");
			return;
		}
		var trs = $("tr.addItemManualRow");
		tr = trs.eq(++addItemManualIdx);

		tr.show();
	});

	//説明書ダウンロード
	$(".downLoadItemManual").click (function () {
		$("#sysItemManualId").val($(this).parents(".itemManualRow").find(".sysItemManualId").val());
		goTransactionNew("itemManualDownLoad.do");
	});

	$(".deleteItemManual").click (function () {
		$(this).parents(".itemManualRow").find(".deleteFlag").val("1");
		$(this).parents("tr.itemManualRow").hide();
	});

	//キープ削除
	$(".deleteKeep").click (function () {
		$(this).parents(".keepRow").find(".deleteFlag").val("1");
		$(this).parents("tr.keepRow").hide();
	});

	//外部倉庫キープ削除
	$(".deleteExternalKeep").click (function () {
		$(this).parents(".keepExternalRow").find(".deleteFlag").val("1");
		$(this).parents("tr.keepExternalRow").hide();
	});

	//登録済み不良在庫「削除」ボタン押下時
	$(".deleteDeadStock").click (function () {
		$(this).parents(".deadStockRow").find(".deleteFlag").val("1");
		$(this).parents("tr.deadStockRow").hide();

	});

	//■ただのfunction
	function priorityOptions() {

// 		var selectList = [];
		$(".prioritySelect").each(function (){

// 			selectList.push($(".prioritySelect").val());
			$(".priorityOptions").remove($(".prioritySelect").val());
		});
	}


	//商品登録時、倉庫、優先度を選択状態にする
	function addValueWarehouse() {

		for (var i = 0; i < $("#warehouseLength").val(); i++) {
			$('select[name="addWarehouseStockList['+ i +']priority"]').val(i + 1);
			$('select[name="addWarehouseStockList['+ i +']sysWarehouseId"]').val(i + 1);
		}
	}

	function appendPrioritySelect () {

		var length = $(".warehouseNum").length + addWarehouseIdx + 1;
		$(".prioritySelect").append($('<option>').html(length).val(length));
	}
	function removePrioritySelect () {

		$(".prioritySelect").each(function () {

			$(".priorityOptions").remove().appendTo($(".prioritySelect").val());
		});
	}

	//20140821 k.saito 商品詳細画面倉庫修正判定
	//20161101 n_nozawa
	function warehouseStockAlert (showTr, addShowTr) {
		var errorFlg = true;
		var registered = true;
		showTr.each(function(){
			//登録分の優先度、倉庫名が消されている判定
			for (var i = 0; i < showTr.size(); i++) {
				var prioritySelect = showTr.eq(i).find(".prioritySelect").val();
				var sysWarehouseId = showTr.eq(i).find(".sysWarehouseId").val();
				var stockNum = new Number(showTr.eq(i).find(".stockNum").val());

				if (prioritySelect == "" || sysWarehouseId == "") {

					registered = false;
					alert('登録済みの優先度・倉庫名は必須項目です。');
					return false;
				} else if(stockNum > 0) {

					if (prioritySelect == "" || sysWarehouseId == "") {

						registered = false;
						alert('登録済みの優先度・倉庫名は必須項目です。');
						return false;
					}
				}
			}
			//追加分の優先度、倉庫名が片方だけの判定
			for (var i = 0; i <= addWarehouseIdx; i++) {
				var addprioritySelect = addShowTr.eq(i).find(".prioritySelect").val();
				var addsysWarehouseId = addShowTr.eq(i).find(".sysWarehouseId").val();
				var stockNum = new Number(addShowTr.eq(i).find(".stockNum").val());

				if (addprioritySelect != "" || addsysWarehouseId != "") {

					if (addprioritySelect == "" || addsysWarehouseId == "") {

						registered = false;
						alert('優先度・倉庫名は必須項目です。');
						return false;
					} else if(stockNum > 0) {

						if (addprioritySelect == "" || addsysWarehouseId == "") {

							registered = false;
							alert('優先度・倉庫名は必須項目です。');
							return false;
						}
					}
				}
			}
		});
		if (registered == true) {

			//優先度に抜けがあるかの判定
			var arr = [];
			for (var i = 0; i <= showTr.size() + addWarehouseIdx; i++) {
				arr[i] = i + 1;
			}

			var notFoundCount = 0;
			for (var i = 0; i <= addWarehouseIdx; i++) {

				if (addShowTr.eq(i).find(".prioritySelect").val() == "") {
					notFoundCount++;
				}
			}

			for (var i = 0; i <= showTr.size() + addWarehouseIdx - notFoundCount; i++) {
				var numChck = true;

				for (var j = 0; j <= showTr.size(); j++) {
					//表示分
					var prioritySelect = showTr.eq(j).find(".prioritySelect").val();
					var sysWarehouseId = showTr.eq(j).find(".sysWarehouseId").val();
					var stockNum = new Number(showTr.eq(j).find(".stockNum").val());

					if (prioritySelect == arr[i]) {
						numChck = true;
						break;
					}
					if (prioritySelect != arr[i]) {
						numChck = false;
					}
				}

				if (numChck == false) {
					for (var k = 0; k <= addWarehouseIdx; k++) {

						//追加分
						var addprioritySelect = addShowTr.eq(k).find(".prioritySelect").val();
						var addsysWarehouseId = addShowTr.eq(k).find(".sysWarehouseId").val();
						var addstockNum = new Number(addShowTr.eq(k).find(".stockNum").val());

						if (addprioritySelect == "") {
							continue;
						}

						if (addprioritySelect == arr[i]) {
							numChck = true;
							break;
						}
					}
				}
				if (numChck == false) {

					alert('優先度に誤りがあります。');
						return false;
				}
			}
			//優先度に重複があるかの判定
			var numChck = false;
			var douarr = [];
			var i = 0;
			for (i = 0; i < showTr.size(); i++) {
				douarr[i] = showTr.eq(i).find(".prioritySelect").val();
			}

			for (var j = 0; j <= addWarehouseIdx; i++, j++) {

				douarr[i] = addShowTr.eq(j).find(".prioritySelect").val();
			}

			for (var k = 0; k <= showTr.size() + addWarehouseIdx - notFoundCount; k++) {
				for (var j = 0; j <= showTr.size() + addWarehouseIdx; j++) {

					if (douarr[j] == "") {
						continue;
					}
					if (douarr[k] == douarr[j] && k != j) {

						alert('優先度に誤りがあります。');
							return false;
					}
				}
			}
			//倉庫名に重複があるかの判定
			var i = 0;
// 			alert($(".sysWarehouseId option:selected").val() + ",");
			//登録分を配列に格納
			var douarr = [];
			for (i = 0; i < showTr.size(); i++) {
				douarr[i] = showTr.eq(i).find(".sysWarehouseId").val();
			}

			//追加分を配列に格納
			for (var j = 0; j <= addWarehouseIdx; i++, j++) {

				douarr[i] = addShowTr.eq(j).find(".sysWarehouseId").val();
			}

			for (var k = 0; k <= $(".warehouseNum").length + addWarehouseIdx; k++) {
				for (var j = 0; j <= $(".warehouseNum").length + addWarehouseIdx; j++) {

					if (douarr[j] == "") {
						continue;
					}

					//重複した数字で、配列の位置がちがければ重複判定
					if (douarr[k] == douarr[j] && k != j) {

						alert('倉庫名が重複しています。');
							return false;
					}
				}
			}
			return errorFlg;
		}
	}



	//20140821 k.saito 商品登録画面倉庫在庫追加登録判定
	function addWarehouseStockAlert (showTr) {

		for (var i = 0; i <= addWarehouseIdx; i++) {

			var prioritySelect = showTr.eq(i).find(".prioritySelect").val();
			var sysWarehouseId = showTr.eq(i).find(".sysWarehouseId").val();
			var stockNum = new Number(showTr.eq(i).find(".stockNum").val());

			if (prioritySelect != "" || sysWarehouseId != "") {

				if (prioritySelect == "" || sysWarehouseId == "") {

					alert('優先度・倉庫名は必須項目です。');
					return false;

				} else if(stockNum > 0) {
					if (prioritySelect == "" || sysWarehouseId == "") {

						alert('優先度・倉庫名は必須項目です。');
						return false;
					}
				}
			}
		}
		//優先度に抜けがあるかの判定
		var arr = [];
		for (var i = 0; i <= addWarehouseIdx; i++) {
			arr[i] = i + 1;
		}

		//空行分は判定に入れないためカウント
		var notFoundCount = 0;
		for (var i = 0; i <= addWarehouseIdx; i++) {

			if (showTr.eq(i).find(".prioritySelect").val() == "") {
				notFoundCount++;
			}
		}
		var numChck = true;
		for (var i = 0; i <= addWarehouseIdx - notFoundCount; i++) {
			for (var k = 0; k <= addWarehouseIdx; k++) {
				var addprioritySelect = showTr.eq(k).find(".prioritySelect").val();
				var addsysWarehouseId = showTr.eq(k).find(".sysWarehouseId").val();
				var addstockNum = new Number(showTr.eq(k).find(".stockNum").val());

				if (addprioritySelect == "") {
					continue;
				}

				if (addprioritySelect == arr[i]) {
					numChck = true;
					break;
				}

				if (addprioritySelect != arr[i]) {
					numChck = false;
				}
			}

			if (numChck == false) {

				alert('優先度に誤りがあります。');
				return false;
			}
		}
		//優先度に重複があるかの判定
		var numChck = false;
		var douarr = [];
		var i = 0;
		for (i = 0; i < showTr.size(); i++) {
			douarr[i] = showTr.eq(i).find(".prioritySelect").val();
		}

		for (var j = 0; j <= addWarehouseIdx; i++, j++) {

			douarr[i] = showTr.eq(j).find(".prioritySelect").val();
		}

		for (var k = 0; k <= addWarehouseIdx - notFoundCount; k++) {
			for (var j = 0; j <= addWarehouseIdx; j++) {

				if (douarr[j] == "") {
					continue;
				}
				if (douarr[k] == douarr[j] && k != j) {

					alert('優先度に誤りがあります。');
						return false;
				}
			}
		}
		//倉庫名に重複があるかの判定
		//追加分を配列に格納
		var douarr = [];
		var i = 0;
		for (i = 0; i <= addWarehouseIdx; i++) {
			douarr[i] = showTr.eq(i).find(".sysWarehouseId").val();
		}

		for (var k = 0; k <= addWarehouseIdx; k++) {
			for (var j = 0; j <= addWarehouseIdx; j++) {

				if (douarr[j] == "") {
					continue;
				}

				//重複した数字で、配列の位置がちがければ重複判定
				if (douarr[k] == douarr[j] && k != j) {

					alert('倉庫名が重複しています。');
						return false;
				}
			}
		}
		return true;
	}

	function addBackOrderAlert (showTbody) {

		for (var i = 0; i <= addBackOrderIdx; i++) {

			var addBackOrderDate = showTbody.eq(i).find(".addBackOrderDate").val();
			var sysCorporationId = new Number(showTbody.eq(i).find(".sysCorporationId").val());
			var sysChannelId = new Number(showTbody.eq(i).find(".sysChannelId").val());
			var remarks = showTbody.eq(i).find(".remarks").val();

			if (sysCorporationId != 0 || sysChannelId != 0 || remarks != "") {

				if (addBackOrderDate == "" || sysCorporationId == 0 || sysChannelId == 0) {

					alert('BO日・法人・販売チャネルは必須項目です。');
					return false;
				}
			}
		}
		return true;
	}

	//登録済み資料修正判定
	function documentAlert () {

		// 登録済み資料の資料区分が空白に変更されていた場合、アラートを表示させる。
		var documentErrorFlg = true;

		$(".itemManualRow").each(function(idx,itemManualList){
			var documentType = $("#documentType" + idx).val();
			var documentDltFlg = $("#documentDeleteFlag" + idx).val();

			if (documentDltFlg != "1") {
				if(documentType == "") {
					alert("資料区分は空白には出来ません。");
					documentErrorFlg = false;
					return false;
				}
			}
		});
		return documentErrorFlg;
	}

	//資料追加登録判定
	function addDocumentAlert () {

		/* 資料区分が空白の状態で資料を登録した場合、
			または、資料区分を選択し、登録する資料が選択されていない場合、アラートを表示させる。*/
		var addDocumentErrorFlg = true;
		$(".addItemManualRow").each(function(idx,addItemManualList){
			var addDocumentType = $("#addDocumentType" + idx).val();
			var addManualFile = $("#addManualFile" + idx).val();

			if(addDocumentType == "" && addManualFile != "") {
				alert("資料区分は空白には出来ません。");
				addDocumentErrorFlg = false;
				return false;
			}

			if(addDocumentType != "" && addManualFile == "") {
				alert("資料が選択されていません。");
				addDocumentErrorFlg = false;
				return false;
			}
		});
		return addDocumentErrorFlg;
	}
	//説明書日本語入力NGチェック(追加時)
	$(".manualFile").change (function () {
		var file = this.files[0];

		var isJapanese = false;  //日本語（英語以外）の場合「true」に設定
		for(var i=0; i < file.name.length; i++){
		    if(file.name.charCodeAt(i) >= 256) {
		      isJapanese = true;
		      break;
		    }
		}

		//日本語（英語以外）の場合
		if(isJapanese) {
			alert("ファイル名は、半角英数字のみ入力してください。");
			$(this).val("");
		}

	});

	//説明書日本語入力NGチェック(更新時)
	$(".hideManualFile").change (function () {
		var file = this.files[0];

		var isJapanese = false;  //日本語（英語以外）の場合「true」に設定
		for(var i=0; i < file.name.length; i++){
		    if(file.name.charCodeAt(i) >= 256) {
		      isJapanese = true;
		      break;
		    }
		}

		//日本語（英語以外）の場合
		if(isJapanese) {
			alert("ファイル名は、半角英数字のみ入力してください。");
			$(this).val("");
			var idname = $(this).attr("id");
			if (idname.length != 0) {
				var num = idname.slice(idname.length - 1);
				$("#manualFileNameDisp" + num).val("");
			}
		}

	});

	//仕入金額入力制御
	$("#purchaceCost").blur (function () {
		var str = $("#purchaceCost").val();
		if (!str.match(/^[0-9.]*$/)) {
			alert("半角数字と小数点以外は入力できません。");
			$("#purchaceCost").val("");
			return false;
		}

		//仕入金額の桁数制御
		if ($("#purchaceCost").val() >= 10000000) {
			alert("仕入金額は7桁までです。");
			$('#purchaceCost').val(0.0)
			return false;
		}

		if (str == "") {
			$("#purchaceCost").val("0.0");
		} else {
			var purchaceCost = $("#purchaceCost")[0];
			addComma(purchaceCost);
		}
		return true;
	});
	$("#purchaceCost").focus (function () {
		var str = $("#purchaceCost").val();
		if (str == 0.0) {
			$("#purchaceCost").val("");
		} else {
			$("#purchaceCost").val(removeComma($("#purchaceCost").val()))
		}
		return true;
	});

	//工場IDが0の場合空にする
	$("#supplierId").focus(function () {
		if ($("#supplierId").val() == 0) {
			$("#supplierId").val("");
		}
		return true;
	})

		//半角数字
	$(".numTextItemCode").blur(function () {

		if (!numberCheckCormal(this)){
			$(this).val('');
			return;
		}
	});

});

//金額の項目にカンマをつける
function commmaAddFnc() {
	for (var i = 0; i < $(".itemCost").size(); i++) {

		//送料
		var cost = $(".cost").eq(i)[0];
		//定価
		var price = $(".price").eq(i)[0];

		price = addComma(price);
		cost = addComma(cost);
	}
};
</script>
	</head>
	<jsp:include page="/WEB-INF/page/common/menu.jsp" />
	<nested:form action="/detailItem" enctype="multipart/form-data">

	<nested:nest property="registryMessageDTO">
		<nested:hidden property="messageFlg" styleId="messageFlg"/>
		<nested:notEmpty property="registryMessage">
			<div id="messageArea" class="">
				<p class="registryMessage" style="text-align: leght;">
					<nested:write property="registryMessage"/>
				</p>
			</div>
		</nested:notEmpty>
	</nested:nest>

	<nested:equal value="0" property="mstItemDTO.sysItemId">
		<h4 class="headingDetailReg">商品登録</h4>
	</nested:equal>
	<nested:notEqual value="0" property="mstItemDTO.sysItemId">
		<div class="headingDetail">商品詳細&nbsp;&nbsp;&nbsp;<span class="explainLabel">編集後は、必ず「更新」ボタンを押してください。</span></div>
	</nested:notEqual>

	<!-- 	仕入先検索用情報 -->
	<nested:hidden property="searchSysSupplierId" styleId="searchSysSupplierId" />

	<nested:hidden property="overseasInfoAuth" styleId="overseasInfoAuth"></nested:hidden>
	<nested:hidden property="alertType" styleId="alertType"></nested:hidden>
<!-- 	画面上に追加できる行の上限 -->
	<nested:hidden property="warehouseLength" styleId="warehouseLength"/>
	<nested:hidden property="addArrivalScheduleLength" styleId="addArrivalScheduleLength"/>
	<nested:hidden property="addKeepLength" styleId="addKeepLength"/>
	<nested:hidden property="addExternalKeepLength" styleId="addExternalKeepLength"/>
	<nested:hidden property="addDeadStockLength" styleId="addDeadStockLength"/>
	<nested:hidden property="addBackOrderLength" styleId="addBackOrderLength"/>
	<nested:hidden property="addItemManualLength" styleId="addItemManualLength"/>
	<nested:hidden property="sysItemManualId" styleId="sysItemManualId"/>

		<nested:notEmpty property="errorMessageDTO">
		<nested:nest property="errorMessageDTO">
			<p style="text-align: center; font-weight:bold; color:red;"><nested:write property="errorMessage"/></p>
		</nested:nest>
		</nested:notEmpty>

		<nested:nest property="mstItemDTO">
			<nested:hidden property="sysItemId" styleId="newItemregistry" />
			<div id="leftArea">
				<div id="detailArea">
					<table class="list" style="width: 100%;">
						<tr>
							<th class="w100">品番<label class="necessary">※</label></th>
							<td>&nbsp;<nested:text property="itemCode" styleClass="w120 numTextItemCode codeCheck" maxlength="11" /></td>
<%-- 								<nested:hidden property="beforeItemCode" /> --%>
							<th class="w100">旧品番</th>
							<td><nested:text property="oldItemCode" styleClass="w100" maxlength="30" /></td>
<%-- 							<nested:hidden property="beforeOldItemCode" /> --%>
						</tr>
						<tr>
							<th>商品名<label class="necessary">※</label></th>
							<td colspan="3">
								<nested:textarea property="itemNm" style="width: 400px;" styleClass="itemNmCheck" cols="20" rows="1" onfocus="PxTextareaAdjuster(this);" onkeyup="PxTextareaAdjuster(this);"
										onchange="PxTextareaAdjuster(this);" onblur="PxTextareaAdjuster(this);">
								</nested:textarea>
<%-- 								<nested:hidden property="beforeItemNm" /> --%>
							</td>
						</tr>
						<tr>
							<th>車種</th>
							<td colspan="3">
								<nested:textarea property="carModel" style="width: 400px;" styleClass="carModel" cols="20" rows="1" onfocus="PxTextareaAdjuster(this);" onkeyup="PxTextareaAdjuster(this);"
										onchange="PxTextareaAdjuster(this);" onblur="PxTextareaAdjuster(this);">
								</nested:textarea>
<%-- 								<nested:hidden property="beforeCarModel" /> --%>
							</td>
						</tr>
						<tr>
							<th>型式</th>
							<td colspan="3">
								<nested:textarea property="model" style="width: 400px;" styleClass="model" cols="20" rows="1" onfocus="PxTextareaAdjuster(this);" onkeyup="PxTextareaAdjuster(this);"
										onchange="PxTextareaAdjuster(this);" onblur="PxTextareaAdjuster(this);">
								</nested:textarea>
<%-- 								<nested:hidden property="beforeModel" /> --%>
							</td>
						</tr>
						<tr>
							<th>メーカー</th>
							<td colspan="3">
								<nested:text property="makerNm" styleClass="makerNm" styleId="makerNm"/>
<%-- 								<nested:hidden property="beforeMakerNm" /> --%>
							</td>
						</tr>
						<tr>
							<th>仕様メモ</th>
							<td colspan="3">
								<nested:textarea property="specMemo" style="width: 400px;" styleClass="specMemo" cols="20" rows="1" onfocus="PxTextareaAdjuster(this);" onkeyup="PxTextareaAdjuster(this);"
										onchange="PxTextareaAdjuster(this);" onblur="PxTextareaAdjuster(this);">
								</nested:textarea>
<%-- 								<nested:hidden property="beforeSpecMemo" /> --%>
							</td>
						</tr>

						<tr>
							<th>在庫<br/>アラート数</th>
							<td><nested:text property="orderAlertNum" styleClass="num numText" maxlength="4" /></td>
<%-- 							<nested:hidden property="beforeOrderAlertNum" /> --%>
							<th>商品<br/>リードタイム</th>
							<td class="w150">
								<nested:select property="itemLeadTime" styleId="itemLeadTime">
									<html:optionsCollection property="itemLeadTimeMap" label="value" value="key"/>
								</nested:select>
<%-- 								<nested:hidden property="beforeItemLeadTime" /> --%>
							</td>
						</tr>
						<tr>
							<th>
								注文履歴
								(平均)<br>
							</th>
							<td class="w150"><span class="totalNumLabel"><nested:write property="annualAverageSalesNum" /></span></td>

						</tr>
						<tr>
							<th>梱包<br/>サイズ</th>
							<td><nested:text property="packingSize" styleClass="text_w100" style="text-align: right;" />&nbsp;cm</td>
<%-- 								<nested:hidden property="beforePackingSize" /> --%>
							<th>重量</th>
							<td><nested:text property="weight" styleClass="numText text_w100" style="text-align: right;" />&nbsp;kg</td>
<%-- 								<nested:hidden property="beforeWeight" /> --%>
						</tr>
						<tr>
							<th>総在庫数</th>
							<td class="w150"><span class="totalNumLabel"><nested:write property="totalStockNum" />&nbsp;(<nested:write property="temporaryStockNum" />)</span></td>
<%-- 											<nested:hidden property="beforeTotalStockNum" /> --%>
							<th>最小<br/>ロット数</th>
							<td class="w150"><span class="minimumOrderQuantity"><nested:text property="minimumOrderQuantity" styleClass="numText text_w100 num" style="text-align: right;"/></span></td>
<%-- 											<nested:hidden property="beforeMinimumOrderQuantity" /> --%>
						</tr>
					</table>

					<logic:equal name="itemForm" value="1" property="overseasInfoAuth">
						<table id="detailArea">
							<tr>
								<th class="titleSize">工場品番</th>
								<td class="padding_zero"><nested:text property="factoryItemCode" styleClass="factoryItemCode textareaSize" styleId="factoryItemCode" /></td>
<%-- 								<nested:hidden property="beforeFactoryItemCode" /> --%>
								<th class="titleSizeSub">仕入国</th>
								<td>
									<nested:text property="purchaceCountry" styleClass="purchaceCountry text_w160" styleId="purchaceCountry" />
<%-- 									<nested:hidden property="beforePurchaceCountry" /> --%>
								</td>
							</tr>
							<tr>
								<th>仕入金額</th>
								<td>
									<span id="currencyType" class="currencyType"><bean:write name="itemForm" property="supplierDTO.currencyType" /></span>
									<nested:text property="purchaceCost" styleClass="purchaceCost text_w100" styleId="purchaceCost" style="text-align: right;" />
<%-- 									<nested:hidden property="beforePurchaceCost" /> --%>
								</td>
								<th>通貨</th>
								<td class="w150">
									<span id="currencyType" class="currencyType"><bean:write name="itemForm" property="supplierDTO.currencyType" /></span>
									&nbsp;（<span id="currencyNm" class="currencyNm"><bean:write name="itemForm" property="supplierDTO.currencyNm" /></span>）
									<html:hidden name="itemForm" property="supplierDTO.rate" styleClass="rate" styleId="rate" />
								</td>
							</tr>
							<tr>
								<th>海外<br/>商品名</th>
								<td colspan="3">
									<nested:textarea property="foreignItemNm" style="width: 400px;" styleClass="foreignItemNm" styleId="foreignItemNm"
										cols="20" rows="1" onfocus="PxTextareaAdjuster(this);" onkeyup="PxTextareaAdjuster(this);"
									 	onchange="PxTextareaAdjuster(this);" onblur="PxTextareaAdjuster(this);">
<%-- 									 	<nested:hidden property="beforeForeignItemNm" /> --%>
									</nested:textarea>
								</td>
							</tr>
							<tr>
								<th>会社<br/>工場名</th>
								<td colspan="3">
									<nested:hidden property="sysSupplierId" styleClass="sysSupplierId" styleId="sysSupplierId"/>
									<nested:text property="supplierId" styleClass="supplierId text_w100" style="text-align: right;" styleId="supplierId"/>
<%-- 									<nested:hidden property="beforeSysSupplierId" /> --%>
									&nbsp;<a href="Javascript:void(0);" class="button_main" id="searchSupplier">検索</a>
									<br></br>
									<span id="companyFactoryNm"  class="companyFactoryNm" ><bean:write name="itemForm" property="supplierDTO.companyFactoryNm"/></span>
								</td>
							</tr>
						</table>
					</logic:equal>
				</div>

				<table id="warehouseArea">
					<tr>
						<th style="min-width: 55px;">優先度</th>
						<th style="min-width: 100px;">倉庫名</th>
						<th style="min-width: 60px;">在庫数</th>
						<th colspan="2" style="min-width: 200px;max-width: 200px">ロケーションNo</th>
					</tr>

<!-- 					表示用 -->
					<logic:notEmpty name="itemForm" property="warehouseStockList">
					<logic:iterate id="warehouseStockList" name="itemForm" property="warehouseStockList" indexId="idx">
						<html:hidden property="warehouseStockList[${idx}]sysWarehouseStockId" />
							<tr class="warehouseStockRow">
								<td><html:select property="warehouseStockList[${idx}]priority" styleClass="prioritySelect warehouseNum">
									<html:option value="">　</html:option>
									<html:optionsCollection name="itemForm" property="warehouseStockList" label="priority" value="priority" styleClass="priorityOptions" />
								</html:select></td>
									<html:hidden property="warehouseStockList[${idx}]beforePriority" />

								<td><html:select property="warehouseStockList[${idx}]sysWarehouseId" styleClass="sysWarehouseId">
									<html:option value="">　</html:option>
									<html:optionsCollection property="warehouseList" label="warehouseNm" value="sysWarehouseId" styleClass="sysWarehouseId" />
								</html:select></td>
								<td><html:text property="warehouseStockList[${idx}]stockNum"  styleClass="num stockNum numText" maxlength="4" /></td>
									<html:hidden property="warehouseStockList[${idx}]beforeStockNum" />
								<td colspan="2" class="border_shadow"><html:text property="warehouseStockList[${idx}]locationNo"  styleClass="w100" maxlength="30" /></td>
												<html:hidden property="warehouseStockList[${idx}]beforeLocationNo" />
							</tr>
						</tbody>
					</logic:iterate>
					</logic:notEmpty>
<!-- 					追加用 -->
					<logic:notEmpty name="itemForm" property="addWarehouseStockList">
					<logic:iterate id="addWarehouseStockList" name="itemForm" property="addWarehouseStockList" indexId="idx">
							<tr class="addWarehouseStockRow">
								<td><html:select property="addWarehouseStockList[${idx}]priority" styleClass="prioritySelect addWarehouseNum priority">
									<html:option value="">　</html:option>
									<html:optionsCollection name="itemForm" property="warehouseStockList" label="priority" value="priority"
										styleClass="priorityOptions" />
								</html:select></td>
								<td><html:select property="addWarehouseStockList[${idx}]sysWarehouseId" styleClass="sysWarehouseId" >
									<option value="">　</option>
									<html:optionsCollection property="warehouseList" label="warehouseNm" value="sysWarehouseId" />
								</html:select></td>
								<td><html:text property="addWarehouseStockList[${idx}]stockNum"  styleClass="num stockNum numText" maxlength="4" /></td>
								<td><html:text property="addWarehouseStockList[${idx}]locationNo" styleClass="w100 locationNo" maxlength="30" /></td>
								<nested:notEqual value="0" property="sysItemId">
								<td class="wTdButton"><a href="Javascript:void(0);" style="max-width: 50px; min-width: 50px;" class="button_small_white removeWarehouse wButton">削除</a></td>
								</nested:notEqual>
							</tr>
						</tbody>
					</logic:iterate>
					</logic:notEmpty>
				</table>

				<!-- 外部倉庫 -->
				<table id="externalWarehouseArea">
					<tr>
						<th style="min-width: 100px;">倉庫名</th>
						<th style="min-width: 60px;">在庫数</th>
					</tr>

					<logic:notEmpty name="itemForm" property="externalWarehouseStockList">
						<logic:iterate id="externalWarehouseStockList" name="itemForm" property="externalWarehouseStockList" indexId="idx">
							<html:hidden property="externalWarehouseStockList[${idx}]sysExternalWarehouseCode" />
								<tr class="externalWarehouseStockRow">
									<td><html:select property="externalWarehouseStockList[${idx}]sysExternalWarehouseCode" >
										<html:optionsCollection property="externalWarehouseList" label="warehouseNm" value="sysExternalWarehouseCode" />
									</html:select></td>
									<td><html:text property="externalWarehouseStockList[${idx}]stockNum"  styleClass="num stockNum numText" maxlength="4" /></td>
									<html:hidden property="externalWarehouseStockList[${idx}]beforeStockNum" />
								</tr>
						</logic:iterate>
					</logic:notEmpty>
				</table>


				<table id="deadStockArea">
					<tr>
						<th>不良原因</th>
						<th>個数</th>
						<th></th>
					</tr>
<!-- 					表示用 -->
					<logic:notEmpty name="itemForm" property="deadStockList">
						<logic:iterate name="itemForm" id="deadStockList" property="deadStockList" indexId="idx">
							<tr class="deadStockRow">
								<html:hidden name="itemForm" property="deadStockList[${idx}]sysDeadStockId" />
								<html:hidden name="itemForm" property="deadStockList[${idx}]deleteFlag" styleClass="deleteFlag"/>
								<td><html:text styleClass="addDeadReason w300" property="deadStockList[${idx}]deadReason" maxlength="30"/></td>
								<td><html:text styleClass="num addItemNum numText" property="deadStockList[${idx}]itemNum" maxlength="4"/></td>
								<td><a class="button_small_white deleteDeadStock" href="Javascript:void(0);">削除</a></td>
							</tr>
						</logic:iterate>
					</logic:notEmpty>
<!-- 					追加用 -->
					<logic:notEmpty name="itemForm" property="addDeadStockList">
						<logic:iterate name="itemForm" id="addDeadStockList" property="addDeadStockList" indexId="idx">
							<tr class="addDeadStockRow">
								<td><html:text styleClass="addDeadReason w300" property="addDeadStockList[${idx}]deadReason" maxlength="30"/></td>
								<td><html:text styleClass="num addItemNum numText" property="addDeadStockList[${idx}]itemNum" maxlength="4"/></td>
								<td><a class="button_small_white removeDeadStock" href="Javascript:void(0);">削除</a></td>
							</tr>
						</logic:iterate>
					</logic:notEmpty>
				</table>

				<table id="lastUpdateDetail">
					<tr>
						<th>更新情報</th>
					</tr>
					<tr>
						<td class="tdPdg">
							<logic:iterate name="itemForm" id="updateDataHistoryList" property="updateDataHistoryList" indexId="idx">
									<bean:write name="itemForm" property="updateDataHistoryList[${idx}]updateHistory"/><br/>
							</logic:iterate>
						</td>
					</tr>
				</table>

				<table id="lastUpdateDetail">
					<tr>
						<th>最終更新情報</th>
					</tr>
					<tr>
						<td class="tdPdg">
							<bean:write name="itemForm" property="extendMstUserDTO.userFamilyNmKanji"/>
							<bean:write name="itemForm" property="extendMstUserDTO.userFirstNmKanji"/>
							<nested:write property="updateDate" format="yyyy/MM/dd HH:mm:ss"/>
						</td>
					</tr>
				</table>
			</div>
		</nested:nest>

		<div id="rightArea">
			<ul>
				<li><a href="#keep" ><span>キープ</span></a></li><li><a href="#schedule" ><span>入荷予定</span></a></li><li><a href="#record" ><span>入荷履歴</span></a></li><li><a href="#priceInf" ><span>価格情報</span></a></li><li><a href="#manual" ><span>資料</span></a></li>
<!-- 				<li><a href="#backOrder" ><span>BO</span></a></li> -->
			</ul>

			<div id="keep">
				<table id="keepTable">
				<caption id="keepTable-caption" >KTS倉庫</caption>
					<tr>
						<th>受注番号</th>
						<th>個数</th>
						<th>備考</th>
						<th></th>
					</tr>
<!-- 					表示用 -->
					<nested:notEmpty property="keepList">
						<nested:iterate property="keepList" indexId="idx">
							<tr class="keepRow">
								<nested:hidden property="sysKeepId" />
<%-- 								<nested:hidden property="arrivalFlag" styleClass="arrivalFlag" /> --%>
								<nested:hidden property="deleteFlag" styleClass="deleteFlag"/>
<%-- 								<nested:hidden property="arrivalScheduleNum" styleClass="arrivalScheduleNum"/> --%>
<%-- 								<nested:hidden property="arrivalNum" styleClass="arrivalScheduleNum"/> --%>
								<td><nested:text styleClass="orderNo orderNumCheck w300" property="orderNo" maxlength="30"/></td>
								<td><nested:text styleClass="num keepNum numText" property="keepNum" maxlength="4"/></td>
								<td><nested:textarea property="remarks" styleClass="w250 remarks" rows="2" onfocus="PxTextareaAdjuster(this);" onkeyup="PxTextareaAdjuster(this);"
												onchange="PxTextareaAdjuster(this);" onblur="PxTextareaAdjuster(this);"></nested:textarea></td>
								<td><a class="button_small_white deleteKeep" href="Javascript:void(0);">削除</a></td>
							</tr>
						</nested:iterate>
					</nested:notEmpty>
<!-- 					追加用 -->
					<nested:notEmpty property="addKeepList">
						<nested:iterate property="addKeepList" indexId="idx">
							<tr class="addKeepRow">
								<td><nested:text styleClass="addOrderNum orderNumCheck w300" property="orderNo" maxlength="30"/></td>
								<td><nested:text styleClass="num addKeepNum numText" property="keepNum" maxlength="4"/></td>
								<td><nested:textarea property="remarks" styleClass="w250 addRemarks" rows="2" onfocus="PxTextareaAdjuster(this);" onkeyup="PxTextareaAdjuster(this);"
												onchange="PxTextareaAdjuster(this);" onblur="PxTextareaAdjuster(this);"></nested:textarea></td>
								<td><a class="button_small_white removeKeep" href="Javascript:void(0);">削除</a></td>
							</tr>
						</nested:iterate>
					</nested:notEmpty>
				</table>

				<!-- 外部倉庫用のキープ -->
				<table id="externalKeepTable">
				<caption id="externalKeepTable-caption" >楽天倉庫</caption>
					<tr>
						<th>受注番号</th>
						<th>個数</th>
						<th>備考</th>
						<th></th>
					</tr>
<!-- 					表示用 -->
					<nested:notEmpty property="externalKeepList">
						<nested:iterate property="externalKeepList" indexId="idx">
							<tr class="keepExternalRow">
								<nested:hidden property="sysExternalKeepId" />
								<nested:hidden property="deleteFlag" styleClass="deleteFlag"/>
								<td><nested:text styleClass="orderNo orderNumCheck w300" property="orderNo" maxlength="30"/></td>
								<td><nested:text styleClass="num keepNum numText" property="keepNum" maxlength="4"/></td>
								<td><nested:textarea property="remarks" styleClass="w250 remarks" rows="2" onfocus="PxTextareaAdjuster(this);" onkeyup="PxTextareaAdjuster(this);"
												onchange="PxTextareaAdjuster(this);" onblur="PxTextareaAdjuster(this);"></nested:textarea></td>
								<td><a class="button_small_white deleteExternalKeep" href="Javascript:void(0);">削除</a></td>
							</tr>
						</nested:iterate>
					</nested:notEmpty>
<!-- 					追加用 -->
					<nested:notEmpty property="addExternalKeepList">
						<nested:iterate property="addExternalKeepList" indexId="idx">
							<tr class="addExternalKeepRow">
								<td><nested:text styleClass="addOrderNum orderNumCheck w300" property="orderNo" maxlength="30"/></td>
								<td><nested:text styleClass="num addKeepNum numText" property="keepNum" maxlength="4"/></td>
								<td><nested:textarea property="remarks" styleClass="w250 addRemarks" rows="2" onfocus="PxTextareaAdjuster(this);" onkeyup="PxTextareaAdjuster(this);"
												onchange="PxTextareaAdjuster(this);" onblur="PxTextareaAdjuster(this);"></nested:textarea></td>
								<td><a class="button_small_white removeExternalKeep" href="Javascript:void(0);">削除</a></td>
							</tr>
						</nested:iterate>
					</nested:notEmpty>
				</table>
			</div>

			<div id="schedule">
				<table id="scheduleDate" class="list">
					<tr>
						<th class="arrivalSizeOrder">ステータス</th>
						<th class="poNoSize">PoNo.</th>
						<th class="arrivalSizeDate">注文日</th>
						<th class="arrivalSizeDate">入荷予定日</th>
						<th class="arrivalSizeDateText">曖昧入荷日</th>
						<th class="arrivalSizeNum">未入荷数</th>
						<th class="arrivalBtnSize"></th>
						<th></th>
					</tr>
<!-- 					表示用 -->
					<nested:notEmpty property="arrivalScheduleList">
						<nested:iterate property="arrivalScheduleList" indexId="idx">
							<tr class="arrivalScheduleRow">
								<nested:hidden property="sysForeignSlipId" />
								<nested:hidden property="arrivalFlag" styleClass="arrivalFlag" />
								<nested:hidden property="deleteFlag" styleClass="deleteFlag"/>
								<nested:hidden property="arrivalScheduleNum" styleClass="arrivalScheduleNum"/>
								<nested:hidden property="sysForeignSlipId"></nested:hidden>
<%-- 								<nested:hidden property="arrivalNum" styleClass="arrivalScheduleNum"/> --%>
								<td>
									<span class="orderStatus">
										<nested:write property="orderStatusNm" />
									</span>
									<nested:hidden property="orderStatus"></nested:hidden>
								</td>
								<td><span class="poNo"><nested:write property="poNo" /></span></td>
								<nested:empty property="orderStatus">
									<td><nested:text styleClass="dateText calender" property="itemOrderDate" maxlength="10"/></td>
									<td><nested:text styleClass="dateText calender" property="arrivalScheduleDate" maxlength="10"/></td>
									<td><nested:text styleClass="dateText" property="vagueArrivalSchedule" style="width: 200px" maxlength="30"/></td>
									<td><nested:text property="arrivalNum" styleClass="num numText arrivalNum" maxlength="4" /></td>
									<td><a class="button_small_white sceduleDateCompleteButton" href="Javascript:void(0);">入荷数分入荷</a></td>
									<td><a class="button_small_white sceduleDateDeleteButton" href="Javascript:void(0);">削除</a></td>
								</nested:empty>
								<nested:notEmpty property="orderStatus">

									<td><span class=itemOrderDate><nested:write property="itemOrderDate" /></span></td>
	 								<td><span class="arrivalScheduleDate"><nested:write property="arrivalScheduleDate" /></span></td>
	 								<td><span class="vagueArrivalSchedule" ><nested:write property="vagueArrivalSchedule" /></span></td>
	 								<td><span class="arrivalNum"><nested:write property="arrivalNum" /></span></td>
	 								<td></td>
	 								<td></td>
								</nested:notEmpty>
							</tr>
						</nested:iterate>
					</nested:notEmpty>
				</table>
			</div>

			<div id="record">
				<table id="recordTable">
					<tr>
						<th class="w150">注文日</th>
						<th class="w150">入荷日</th>
						<th class="w100">入荷数</th>
					</tr>
					<nested:notEmpty property="arrivalHistoryList">
						<nested:iterate property="arrivalHistoryList" indexId="idx">
							<tr>
								<td class="w120"><nested:write  property="itemOrderDate"/></td>
								<td class="w120"><nested:write property="arrivalScheduleDate"/></td>
								<td class="w135"><nested:write property="arrivalNum"/></td>
							</tr>
						</nested:iterate>
					</nested:notEmpty>
				</table>
			</div>


			<div id="priceInf">
				<logic:equal name="itemForm" value="1" property="overseasInfoAuth">
					<br>
					<p class="autoCalcSize" ><a class="button_main autoCalc" href="javascript:void(0)" >自動計算</a><a class="button_white" id="reset" href="#">リセット</a></p>
					<table class="list priceTable">
						<tr>
							<th>仕入価格</th>
							<td><nested:text property="mstItemDTO.purchacePrice" styleId="purchacePrice" styleClass="purchacePrice w120 priceText" style="text-align: right;" maxlength="11" /></td>
							<th>加算経費</th>
							<td><nested:text property="mstItemDTO.loading" styleId="loading" styleClass="loading w120 priceText" style="text-align: right;" maxlength="30" /></td>
							<th>kind原価</th>
							<td><html:text property="mstItemDTO.kindCost" styleId="kindCost" styleClass="w120 priceText" style="text-align: right;" maxlength="30" /></td>
							<html:hidden property="mstItemDTO.kindCostId"/>
						</tr>
					</table>
				</logic:equal>
				<table class="list costList">
					<tr>
<!-- 							<td colspan="2">原価</td> -->
						<th>原価</th>
						<th>金額</th>
					</tr>
					<nested:iterate property="itemCostList" indexId="idx">
						<nested:hidden property="sysItemCostId" />
						<tr id="itemCost" class="itemCost">
							<nested:hidden property="sysCorporationId" />
							<td><nested:write property="corporationNm"/></td>
							<td><nested:text property="cost" styleId="cost${idx}" styleClass="cost priceText" style="width: 100px; text-align: right;" maxlength="9"/></td>
<%-- 							<nested:equal value=""> --%>
<!-- 								<td><button id="costCopy">コピー</button></td> -->
<%-- 							</nested:equal> --%>
						</tr>
					</nested:iterate>
				</table>

				<table class="list priceList">
					<tr class="itemPrice">
<!-- 							<td colspan="2">売価</td> -->
						<th>売価</th>
						<th>金額</th>
					</tr>
					<nested:iterate property="itemPriceList" indexId="idx">
						<nested:hidden property="sysItemPriceId" />
						<tr>
							<nested:hidden property="sysCorporationId" />
							<td><nested:write property="corporationNm"/></td>
							<td><nested:text property="price" styleId="price${idx}"
									styleClass="priceText price" style="width: 100px; text-align: right;" maxlength="9"/></td>
						</tr>
					</nested:iterate>
				</table>
			</div>

			<div id="manual">
				<table id="fileArea">
					<tr>
					</tr>
<!-- 					表示用 -->
					<nested:notEmpty property="itemManualList">
						<nested:iterate id="itemManualList" property="itemManualList" indexId="idx">
							<tr class="itemManualRow">
							<html:hidden property="itemManualList[${idx}]sysItemManualId"  styleClass="sysItemManualId"/>
							<html:hidden property="itemManualList[${idx}]sysItemId" />
							<html:hidden property="itemManualList[${idx}]deleteFlag" styleClass="deleteFlag" styleId="documentDeleteFlag${idx}"/>
							<html:hidden property="itemManualList[${idx}]manualPath" styleClass="manualPath"/>

								<td colspan="1">
								<html:select property="itemManualList[${idx}]documentType" styleId="documentType${idx}">
									<html:optionsCollection property="documentTypeMap" label="value" value="key"/>
								</html:select>
								<html:file property="itemManualList[${idx}]manualFile" style="display: none;" styleId="manualFile${idx}" onchange="manualFileNameDisp${idx}.value = this.value;" styleClass="hideManualFile"/>
								<input type="text" name="manualFileNameDisp" value="${itemForm.itemManualList[idx].manualFileNameDisp}" id="manualFileNameDisp${idx}" disabled="disabled"/>
								<input type="button" id="manualButton" class="manualButton${idx}" onclick="manualFile${idx}.click()" value="参照" /></td>
								<td><a class="button_small_main downLoadItemManual" href="Javascript:void(0);">表示</a></td>
								<td><a class="button_small_white deleteItemManual" href="Javascript:void(0);">削除</a></td>
<!-- 								<td><a class="button_small_main" href="Javascript:void(0);">追加</a></td> -->
							</tr>
						</nested:iterate>
					</nested:notEmpty>
<!-- 					追加用 -->
					<nested:notEmpty property="addItemManualList">
						<nested:iterate id="addItemManualList" property="addItemManualList" indexId="idx">
							<tr class="addItemManualRow">
	<%-- 						<html:hidden property="addItemManualList[${idx}]sysItemManualId" /> --%>
	<%-- 						<html:hidden property="addItemManualList[${idx}]deleteFlag" /> --%>
	<%-- 						<html:hidden property="addItemManualList[${idx}]documentType"/> --%>
								<td colspan="2">
									<html:select property="addItemManualList[${idx}]documentType" styleId="addDocumentType${idx}">
										<html:optionsCollection property="documentTypeMap" label="value" value="key" />
									</html:select>
									<html:file property="addItemManualList[${idx}]manualFile" styleId="addManualFile${idx}" styleClass="manualFile" />
								</td>
	<!-- 						<td><a class="button_small_white hideItemManual" href="Javascript:void(0);">削除</a></td> -->
	<!-- 						<td><a class="button_small_main addItemManual" href="Javascript:void(0);">追加</a></td> -->
							</tr>
						</nested:iterate>
					</nested:notEmpty>
				</table>
			<p class="memo">※ファイル名には、半角英数字のみ入力してください。</p>
			<p class="memo">※登録可能なファイルはPDF, JPEG, PNGのみです。</p>
				<table class="memo">
					<tr>
						<th>MEMO</th>
					</tr>
					<tr>
						<td>
							<nested:textarea property="mstItemDTO.documentRemarks" styleClass="w400 remarks" rows="2" onfocus="PxTextareaAdjuster(this);"
							 onkeyup="PxTextareaAdjuster(this);" onchange="PxTextareaAdjuster(this);" onblur="PxTextareaAdjuster(this);" >
							</nested:textarea>
							<nested:hidden property="mstItemDTO.beforeDocumentRemarks"/>
						</td>
					</tr>
				</table>
			</div>


		</div>

		<footer class="footer sPlanning">
			<ul style="position: relative;">
				<li class="footer_button">
					<nested:equal value="0" property="mstItemDTO.sysItemId">
						<a class="button_main registry" href="javascript:void(0)" >登録</a>
					</nested:equal>
				</li>
				<li class="footer_button">
					<nested:notEqual value="0" property="mstItemDTO.sysItemId">
						<a class="button_main update" href="javascript:void(0)" >更新</a>
					</nested:notEqual>
				</li>
				<li class="footer_button">
					<nested:notEqual value="0" property="mstItemDTO.sysItemId">
						<a class="button_white" id="delete" href="#">削除</a>
					</nested:notEqual>
				</li>
			</ul>
		</footer>
	</nested:form>
</html:html>