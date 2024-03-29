<?xml version="1.0" encoding="UTF-8""?>
<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html:html>
	<head>
	<jsp:include page="/WEB-INF/page/define/define-meta.jsp" />
		<title>売上原価入力</title>
	<link rel="stylesheet" href="./css/saleCostList.css" type="text/css" />
	<link rel="stylesheet" href="./css/jquery-ui-1.10.4.custom.min.css" type="text/css" />
	<link rel="stylesheet" href="./css/jquery-ui-1.10.4.custom.css" type="text/css" />
<!-- 	<script type="text/javascript" src="./js/prototype.js"></script> -->
	<script src="./js/fw.js" type="text/javascript" type="text/javascript"></script>
	<script src="./js/jquery-1.10.2.min.js" language="javascript"></script>
	<script src="./js/jquery-ui-1.10.4.custom.min.js" language="javascript"></script>

	<script src="./js/jquery.ui.core.min.js"></script>
	<script src="./js/jquery.ui.datepicker.min.js"></script>
	<script src="./js/jquery.ui.datepicker-ja.min.js"></script>
	<script src="./js/validation.js" type="text/javascript"></script>

<!--
【売上原価一覧画面】
ファイル名：saleCostList.jsp
作成日：2015/12/21
作成者：大山智史

（画面概要）

助ネコ・新規売上登録で生成された売上商品データの検索/一覧画面。

・検索条件：伝票情報か商品情報で絞り込みが可能。検索結果一覧の表示件数も変更可能。
・検索結果：売上商品データ毎の表示。中央右に売上額/原価/粗利の集計。

・検索ボタン押下：設定された絞り込み項目をもとに検索処理を実行する。
・「一括編集する」ボタン押下：検索結果の売上原価一覧を編集可能な一括編集画面へ遷移する。
・行をダブルクリックまたは受注Noリンクをクリック：対象データの売上詳細画面に遷移する。

（注意・補足）

-->


	<script type="text/javascript">

	$(document).ready(function(){
		$(".overlay").css("display", "none");
		$("#sortFirstSub").val(1);

		function calcCost(value1, value2) {

			var listPrice = parseFloat(value1);
			var nrateOver = parseFloat((value2) * 0.01);
			// それぞれの小数点の位置を取得
			var dotPosition1 = getDotPosition(listPrice);
			var dotPosition2 = getDotPosition(nrateOver);

			// 位置の値が大きい方（小数点以下の位が多い方）の位置を取得
			var max = Math.max(dotPosition1, dotPosition2);

			// 大きい方に小数の桁を合わせて文字列化、
			// 小数点を除いて整数の値にする
			var intValue1 = parseFloat((listPrice.toFixed(max) + '').replace('.', ''));
			var intValue2 = parseFloat((nrateOver.toFixed(max) + '').replace('.', ''));

			// 10^N の値を計算
			if (max == 1) {
				max = max + 1;
			} else {
				max = max * 2;
			}
			var power = Math.pow(10, max);

			// 整数値で引き算した後に10^Nで割る
			return [ intValue1, intValue2, power ];

		}

		//小数点の位置を探るメソッド
		function getDotPosition(value) {

			// 数値のままだと操作できないので文字列化する
			var strVal = String(value);
			var dotPosition = 0;

			//小数点が存在するか確認
			// 小数点があったら位置を取得
			if (strVal.lastIndexOf('.') !== -1) {
				dotPosition = (strVal.length - 1) - strVal.lastIndexOf('.');
			}

			return dotPosition;
		}
		
		$('.profitId').each(function(profit){
			var val = removeComma($(this).text());
			val = parseInt(val);
	        
			var color = '';
			if(val < 0 ){
				color = "red";
			}else if(val > 800){
				color = "white";
			}
			$(this).attr('style', 'background-color:'+color+';');
			
			
			var index = $('.profitId').index(this);

			var listPrice = removeComma($(".listPriceEdit").eq(index).text());
			
			// 掛け率取得
			var rateOver = removeComma($(".itemRateOverEdit").eq(index).text());

			// 送料取得
			var postage = removeComma($(".domePostageEdit").eq(index).text());

			// 法人掛け率取得
			var cRateOver = $(".corporationRateOverEdit").eq(index).text();
			if (cRateOver == "") {
				cRateOver = 0;
			}

			// カンマを除去
			listPrice = removeComma(listPrice);
			rateOver = removeComma(rateOver);
			postage = removeComma(postage);
			cRateOver = removeComma(cRateOver);

			// カインドコストの計算処理
			// 定価と掛率に0.01を掛けた数値でカインドコストを算出する。
			var kindCostArray = calcCost(parseInt(listPrice), parseFloat(rateOver)); /// return [intValue1, intValue2, power]
			var tempKindCost = (kindCostArray[0] * kindCostArray[1]) / kindCostArray[2];

			var kindDot = tempKindCost % 10;
			if(kindDot > 0)	tempKindCost = parseInt(tempKindCost) + parseInt(1);
			
			var kindCost = parseInt(tempKindCost) + parseInt(postage);

			kindCost = new String(kindCost).replace(/,/g, "");
			while (kindCost != (kindCost = kindCost.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
			$('.kindCostEdit').eq(index).html(kindCost + "&nbsp;円");
			
			// 原価の計算処理
			// 掛率と法人掛率で定価用の掛率を算出する。
			var rate = parseFloat(rateOver) + parseFloat(cRateOver);

			// 定価と定価用の掛け率から原価（メーカー）を算出
			var costArray = calcCost(listPrice, rate);
			
			var tempCost = (costArray[0] * costArray[1]) / costArray[2];
			
			var dot = tempCost % 10;
			if(dot > 0)	tempCost = parseInt(tempCost) + parseInt(1);
			
			var cost = parseInt(tempCost) + parseInt(postage);

			cost = new String(cost).replace(/,/g, "");
			while (cost != (cost = cost.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
			$('.costEdit').eq(index).html(cost + "&nbsp;円");

			// 単価取得
			var pieceRate = removeComma($(".pieceRateEdit").eq(index).text());
			if (pieceRate == "") {
				pieceRate = 0;
			}
			
			pieceRate = parseInt(pieceRate);
			
			var storeFlag = $(".storeFlag").eq(index).val();
			
			if(storeFlag == '1'){
				var profit = parseInt(pieceRate/1.1)-parseInt(pieceRate*0.1)-parseInt(removeComma(cost))-parseInt(postage);
			}else{
				var profit = pieceRate-parseInt(pieceRate*0.1)-(parseInt(removeComma(cost))+parseInt(postage));
			}

			var color = '';
			if(profit < 0 ){
				color = "red";
			}else if(profit > 800){
				color = "white";
			}
			profit = new String(profit).replace(/,/g, "");
			while (profit != (profit = profit.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
			
			$(this).html(profit + "&nbsp;円");
			$(this).attr('style', 'background-color:'+color+';');
			
		});		

	 });


	$(function() {

		$(".saleCostEdit").click(function(){
			var index = $(".saleCostEdit").index(this);
			
			if($(this).html() == "保存"){

				if (confirm("保存しますか？")) {
					
					$(this).html('編集');

					var sysSalesItemId = $(".sysSalesItemId").eq(index).val();
					var cost = $(".costEdit").eq(index).children('input').val();
					var kindCost = $(".kindCostEdit").eq(index).children('input').val();
					var itemRateOver = $(".itemRateOverEdit").eq(index).children('input').val();
					var listPrice = $(".listPriceEdit").eq(index).children('input').val();
					
					
					if (cost == 0 || cost == "") {
						alert("単価が設定されていません。");
						return;
					}
					if (kindCost == 0 || kindCost == "") {
						alert("Kind原価が設定されていません。");
						return;
					}
					if (listPrice == 0 || listPrice == "") {
						alert("定価が設定されていません。");
						return;
					}
					if (itemRateOver == 0 || itemRateOver == "") {
						alert("掛け率が設定されていません。");
						return;
					}

					
					if($(".costCheck").eq(index).children('input').is(':checked') == true)
						var costCheckFlag = 1;
					else
						var costCheckFlag = 0;
					
					var returnIndex = index;

					
					$.ajax({
						type : 'post',
						url : './saveSaleCostById.do',
						dataType : 'json',
						data : {
							'sysSalesItemId' : sysSalesItemId,
							'cost' : cost,
							'kindCost' : kindCost,
							'itemRateOver' : itemRateOver,
							'listPrice' : listPrice,
							'costCheckFlag' : costCheckFlag,
							'returnIndex' : returnIndex,
							
						}
					}).done(function(data) {

						var idx = data;

						var cost = $(".costEdit").eq(idx).children('input').val();
						cost = new String(cost).replace(/,/g, "");
						while (cost != (cost = cost.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
						$('.costEdit').eq(idx).html(cost + "&nbsp;円");
						
						var kindCost = $(".kindCostEdit").eq(idx).children('input').val();
						kindCost = new String(kindCost).replace(/,/g, "");
						while (kindCost != (kindCost = kindCost.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
						$('.kindCostEdit').eq(idx).html(kindCost + "&nbsp;円");
						
						var domePostage = $(".domePostageEdit").eq(idx).children('input').val();
						domePostage = new String(domePostage).replace(/,/g, "");
						while (domePostage != (domePostage = domePostage.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
						$('.domePostageEdit').eq(idx).html(domePostage + "&nbsp;円");
						
						var listPrice = $(".listPriceEdit").eq(idx).children('input').val();
						listPrice = new String(listPrice).replace(/,/g, "");
						while (listPrice != (listPrice = listPrice.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
						$('.listPriceEdit').eq(idx).html(listPrice + "&nbsp;円");

						var itemRateOver = $(".itemRateOverEdit").eq(idx).children('input').val();
						itemRateOver = new String(itemRateOver).replace(/,/g, "");
						while (itemRateOver != (itemRateOver = itemRateOver.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
						$('.itemRateOverEdit').eq(idx).html(itemRateOver + "&nbsp;%");
						
						$(".costCheck").eq(idx).children('input').prop('disabled', true);
						$(".calcSaleCost").eq(idx).attr('disabled', true);
						$(".reflectLatestSaleCostCost").eq(index).attr('disabled', true);
						
					});

				}

			}else{
				$(this).html('保存');

				$(".calcSaleCost").eq(index).attr('disabled', false);
				$(".reflectLatestSaleCostCost").eq(index).attr('disabled', false);

				var cost = removeComma($(".costEdit").eq(index).text());
				cost = parseInt(cost);
				
				$(".costEdit").eq(index).html("<input type='text' name='cost' id='cost' class='priceText' value='" + cost + "' style='width: 80px; text-align: right;' maxlength='9'>")

				var kindCost = removeComma($(".kindCostEdit").eq(index).text());
				kindCost = parseInt(kindCost);

				$(".kindCostEdit").eq(index).html("<input type='text' name='kindCost' id='kindCost' class='priceText' value='" + kindCost + "' style='width: 80px; text-align: right;' maxlength='9'>")

				var domePostage = removeComma($(".domePostageEdit").eq(index).text());
				domePostage = parseInt(domePostage);

				$(".domePostageEdit").eq(index).html("<input type='text' name='domePostage' id='domePostage' class='priceText' value='" + domePostage + "' style='width: 80px; text-align: right;' maxlength='9'>")

				var listPrice = removeComma($(".listPriceEdit").eq(index).text());
				listPrice = parseInt(listPrice);

				$(".listPriceEdit").eq(index).html("<input type='text' name='listPrice' id='listPrice' class='priceText' value='" + listPrice + "' style='width: 80px; text-align: right;' maxlength='9'>")
			
				var itemRateOver = removeComma($(".itemRateOverEdit").eq(index).text());
				itemRateOver = parseFloat(itemRateOver);

				$(".itemRateOverEdit").eq(index).html("<input type='text' name='itemRateOver' id='itemRateOver' class='priceText' value='" + itemRateOver + "' style='width: 80px; text-align: right;' maxlength='9'>")
			
				$(".costCheck").eq(index).children('input').prop('disabled', false);
				$(".costCheck").eq(index).children('input').prop('checked', true);
			}
		})
		
		// 直近の原価を反映
		$(".reflectLatestSaleCostCost").click(function() {

			// 一覧のインデックスを設定
			$("#sysSalesIndex").val($(".reflectLatestSaleCostCost").index(this));

			var sysSalesIndex = $(".reflectLatestSaleCostCost").index(this);
			
			$.ajax({
				type : 'post',
				url : './reflectLatestSaleCostById.do',
				dataType : 'json',
				data:{
					'sysSalesIndex' : sysSalesIndex,
				}
			}).done(function(data) {

				console.log(data);
				var returnArray = data.split(",");
				
				console.log(returnArray);
				
				var index = returnArray[0];
				var cost = returnArray[1];
				var kindCost = returnArray[2];
				var domePostage = returnArray[3];
				var listPrice = returnArray[4];
				var itemRateOver = returnArray[5];

				$(".costEdit").eq(index).html("<input type='text' name='cost' id='cost' class='priceText' value='" + cost + "' style='width: 80px; text-align: right;' maxlength='9'>")

				$(".kindCostEdit").eq(index).html("<input type='text' name='kindCost' id='kindCost' class='priceText' value='" + kindCost + "' style='width: 80px; text-align: right;' maxlength='9'>")

				$(".domePostageEdit").eq(index).html("<input type='text' name='domePostage' id='domePostage' class='priceText' value='" + domePostage + "' style='width: 80px; text-align: right;' maxlength='9'>")

				$(".listPriceEdit").eq(index).html("<input type='text' name='listPrice' id='listPrice' class='priceText' value='" + listPrice + "' style='width: 80px; text-align: right;' maxlength='9'>")
			
				$(".itemRateOverEdit").eq(index).html("<input type='text' name='itemRateOver' id='itemRateOver' class='priceText' value='" + itemRateOver + "' style='width: 80px; text-align: right;' maxlength='9'>")
			
				$(".costCheck").eq(index).children('input').prop('disabled', false);
				$(".costCheck").eq(index).children('input').prop('checked', true);
			
			});


			return;
		});

		// 入力した原価で金額算出
		$(".calcSaleCost")
				.click(
						function() {

							// 一覧のインデックスを設定
							var index = $(".calcSaleCost").index(this);

							// 定価取得
							var listPrice = $(".listPriceEdit").eq(index).children('input').val();
							
							if (listPrice == 0 || listPrice == "") {
								alert("定価が設定されていません。");
								return;
							}

							// 掛け率取得
							var rateOver = $(".itemRateOverEdit").eq(index).children('input').val();
							if (rateOver == 0 || rateOver == "") {
								alert("掛け率が設定されていません。");
								return;
							}

							// 送料取得
							var postage = $(".domePostageEdit").eq(index).children('input').val();
							if ( postage == 0 || postage == "") {
								alert("送料が設定されていません。");
								return;
							}

							// 法人掛け率取得
							var cRateOver = $(".corporationRateOverEdit").eq(index).text();
							if (cRateOver == "") {
								cRateOver = 0;
							}

							// カンマを除去
							listPrice = removeComma(listPrice);
							rateOver = removeComma(rateOver);
							postage = removeComma(postage);
							cRateOver = removeComma(cRateOver);

							// カインドコストの計算処理
							// 定価と掛率に0.01を掛けた数値でカインドコストを算出する。
							var kindCostArray = calcCost(parseInt(listPrice), parseFloat(rateOver)); /// return [intValue1, intValue2, power]
							var tempKindCost = (kindCostArray[0] * kindCostArray[1]) / kindCostArray[2];
							
							var kindDot = tempKindCost % 10;
							if(kindDot > 0)	tempKindCost = parseInt(tempKindCost) + parseInt(1);
							
							var kindCost = parseInt(tempKindCost) + parseInt(postage);

							$(".kindCostEdit").eq(index).children('input').val(kindCost);
							addComma($(".kindCostEdit").eq(index).children('input').val());

							// 原価の計算処理
							// 掛率と法人掛率で定価用の掛率を算出する。
							var rate = parseFloat(rateOver) + parseFloat(cRateOver);

							// 定価と定価用の掛け率から原価（メーカー）を算出
							var costArray = calcCost(parseInt(listPrice), rate);
							
							var tempCost = (costArray[0] * costArray[1]) / costArray[2];
							
							var dot = tempCost % 10;
							if(dot > 0)	tempCost = parseInt(tempCost) + parseInt(1);
							
							var cost = parseInt(tempCost) + parseInt(postage);

							$(".costEdit").eq(index).children('input').val(cost);
							addComma($(".costEdit").eq(index).children('input').val());
							
							
							// 単価取得
							var pieceRate = removeComma($(".pieceRateEdit").eq(index).text());
							if (pieceRate == "") {
								pieceRate = 0;
							}
							
							pieceRate = parseInt(pieceRate);
							
							console.log(pieceRate);
							var storeFlag = $(".storeFlag").eq(index).val();
							
							if(storeFlag == '1'){
								var profit = parseInt(pieceRate/1.1)-parseInt(pieceRate*0.1)-parseInt(cost)-parseInt(postage);
							}else{
								var profit = pieceRate-parseInt(pieceRate*0.1)-(parseInt(cost)+parseInt(postage));
							}

							var color = '';
							if(profit < 0 ){
								color = "red";
							}else if(profit > 800){
								color = "white";
							}
							profit = new String(profit).replace(/,/g, "");
							while (profit != (profit = profit.replace(/^(-?\d+)(\d{3})/, "$1,$2")));
							
							$('.profitId').eq(index).html(profit + "&nbsp;円");
							$('.profitId').eq(index).attr('style', 'background-color:'+color+';');
							return;

						});

		//Kind原価の計算メソッド (引数：定価、掛率)
		function calcCost(value1, value2) {

			var listPrice = parseFloat(value1);
			var nrateOver = parseFloat((value2) * 0.01);
			// それぞれの小数点の位置を取得
			var dotPosition1 = getDotPosition(listPrice);
			var dotPosition2 = getDotPosition(nrateOver);

			// 位置の値が大きい方（小数点以下の位が多い方）の位置を取得
			var max = Math.max(dotPosition1, dotPosition2);

			// 大きい方に小数の桁を合わせて文字列化、
			// 小数点を除いて整数の値にする
			var intValue1 = parseFloat((listPrice.toFixed(max) + '').replace('.', ''));
			var intValue2 = parseFloat((nrateOver.toFixed(max) + '').replace('.', ''));

			// 10^N の値を計算
			if (max == 1) {
				max = max + 1;
			} else {
				max = max * 2;
			}
			var power = Math.pow(10, max);

			// 整数値で引き算した後に10^Nで割る
			return [ intValue1, intValue2, power ];

		}

		//小数点の位置を探るメソッド
		function getDotPosition(value) {

			// 数値のままだと操作できないので文字列化する
			var strVal = String(value);
			var dotPosition = 0;

			//小数点が存在するか確認
			// 小数点があったら位置を取得
			if (strVal.lastIndexOf('.') !== -1) {
				dotPosition = (strVal.length - 1) - strVal.lastIndexOf('.');
			}

			return dotPosition;
		}
		

	     if($('.slipNoExist').prop('checked') || $('.slipNoHyphen').prop('checked')) {
	    	 $('.slipNoNone').attr('disabled','disabled');
	     }

		 if($('.slipNoNone').prop('checked')) {
		    	$('.slipNoExist').attr('disabled','disabled');
		    	$('.slipNoHyphen').attr('disabled','disabled');
		    }

		if ($("#sysSaleItemIDListSize").val() != 0) {
			var slipPageNum = Math.ceil($("#sysSaleItemIDListSize").val() / $("#saleListPageMax").val());

			$(".slipPageNum").text(slipPageNum);
			$(".slipNowPage").text(Number($("#pageIdx").val()) + 1);

			var i;

			if (0 == $("#pageIdx").val()) {
 				$(".pager > li:eq(3)").find("a").attr("class", "pageNum nowPage");
 				$(".underPager > li:eq(3)").find("a").attr("class", "pageNum nowPage");
			}

			var startIdx;
			// maxDispは奇数で入力
			var maxDisp = 7;
			// slipPageNumがmaxDisp未満の場合maxDispの値をslipPageNumに変更
			if (slipPageNum < maxDisp) {

				maxDisp = slipPageNum;

			}

			var center = Math.ceil(Number(maxDisp) / 2);
			var pageIdx = new Number($("#pageIdx").val());

			// 現在のページが中央より左に表示される場合
			if (center >= pageIdx + 1) {
				startIdx = 1;
				$(".lastIdx").html(slipPageNum);
				$(".liFirstPage").hide();

			// 現在のページが中央より右に表示される場合
			} else if (slipPageNum - (center - 1) <= pageIdx + 1) {

				startIdx = slipPageNum - (maxDisp - 1);
				$(".liLastPage").hide();
				$(".3dotLineEnd").hide();

			// 現在のページが中央に表示される場合
			} else {

				startIdx = $("#pageIdx").val() - (center - 2);
				$(".lastIdx").html(slipPageNum);

			}

			$(".pageNum").html(startIdx);
			var endIdx = startIdx + (maxDisp - 1);

			if (startIdx <= 2) {

 				$(".3dotLineTop").hide();

 			}

			if ((slipPageNum <= 8) || ((slipPageNum - center) <= (pageIdx + 1))) {

				$(".3dotLineEnd").hide();

			}

			if (slipPageNum <= maxDisp) {

				$(".liLastPage").hide();
				$(".liFirstPage").hide();

			}


			for (i = startIdx; i < endIdx && i < slipPageNum; i++) {
				var clone = $(".pager > li:eq(3)").clone();
				clone.children(".pageNum").text(i + 1);

				if (i == $("#pageIdx").val()) {

					clone.find("a").attr("class", "pageNum nowPage");

				} else {
					clone.find("a").attr("class", "pageNum");
				}

 				$(".pager > li.3dotLineEnd").before(clone);
			}
		}
//******************************************************************************************************

		//アラート
		if (document.getElementById('alertType').value != '' && document.getElementById('alertType').value != '0') {
			actAlert(document.getElementById('alertType').value);
			document.getElementById('alertType').value = '0';
		}

	    $(".clear").click(function(){
	        $("#searchOptionArea input, #searchOptionArea select").each(function(){
	            if (this.type == "checkbox" || this.type == "radio") {
	                this.checked = false;
	            } else {
	                $(this).val("");
	            }
	        });
	    });

		$('.num').spinner( {
			max: 9999,
			min: 0,
			step: 1
		});

		$(".calender").datepicker();
		$(".calender").datepicker("option", "showOn", 'button');
		$(".calender").datepicker("option", "buttonImageOnly", true);
		$(".calender").datepicker("option", "buttonImage", './img/calender_icon.png');


		$('#searchOptionOpen').click(function () {

			if($('#searchOptionOpen').text() == "▼絞り込み") {
				$('#searchOptionOpen').text("▲隠す");
			} else {
				$('#searchOptionOpen').text("▼絞り込み");
			}

			$('#searchOptionArea').slideToggle("fast");
		});

		$('.td_editRemarks').dblclick(function() {
			var txt = $(this).text();
			$(this).html('<textarea rows="4" col="50" style="width: 150px;">'+ txt +'</textarea>');
			$('textarea').focus();
		});

		//売上詳細
/*		$(".salesSlipRow").dblclick(function () {

			$("#sysSalesSlipId").val($(this).find(".sysSalesSlipId").val());
			goTransaction("detailSale.do");
		});
*/
		$(".salesSlipLink").click(function () {

			var id = $(this).find(".sysSalesSlipId_Link").val();
			$("#sysSalesSlipId").val(id);
			
			FwGlobal.submitForm(document.forms[0],"/detailSale","detailSale" + $("#sysSalesSlipId").val(),"top=130,left=500,width=780px,height=520px;");

		});

		$(".itemCodeLink").click(function () {

			var value = $(this).find(".itemCode").val();
			
			$("#managementCode").val(value);

			goTransactionNew("searchDomesticExhibition.do");
		});


		$(".pageNum").click (function () {

			if ($("#pageIdx").val() == ($(this).text() - 1)) {

				return;

			}

			$("#pageIdx").val($(this).text() - 1);
			goTransaction("saleCostListPageNo.do");
		});

		//次ページへ
		$("#nextPage").click (function () {

			var maxPage = new Number($(".slipPageNum").eq(0).text());
			if (Number($("#pageIdx").val()) + 1 >= maxPage) {
				alert("最終ページです");
				return;
			}
			$("#pageIdx").val(Number($("#pageIdx").val()) + 1);
			goTransaction("saleCostListPageNo.do");
		});

		//前ページへ
		$("#backPage").click (function () {

			if ($("#pageIdx").val() == 0) {
				alert("先頭ページです");
				return;
			}
			$("#pageIdx").val(Number($("#pageIdx").val()) - 1);
			goTransaction("saleCostListPageNo.do");
		});

//ページ送り（上側）
		//先頭ページへ
		$("#firstPage").click (function () {

			if ($("#pageIdx").val() == 0) {
				alert("先頭ページです");
				return;
			}

			if ($("#pageIdx").val() == ($(this).text() - 1)) {

				return;

			}

			$("#pageIdx").val(0);

			goTransaction("saleCostListPageNo.do");
		});

		//最終ページへ
		$("#lastPage").click (function () {

			var maxPage = new Number($(".slipPageNum").eq(0).text());
			if (Number($("#pageIdx").val()) + 1 >= maxPage) {
				alert("最終ページです");
				return;
			}

			if ($("#pageIdx").val() == ($(this).text() - 1)) {

				return;

			}

			$("#pageIdx").val(maxPage - 1);

			goTransaction("saleCostListPageNo.do");
		});

// ページ送り（下側）
		//次ページへ
		$("#underNextPage").click (function () {

			var maxPage = new Number($(".slipPageNum").eq(0).text());
			if (Number($("#pageIdx").val()) + 1 >= maxPage) {
				alert("最終ページです");
				return;
			}

			if ($("#pageIdx").val() == ($(this).text() - 1)) {

				return;

			}

			$("#pageIdx").val(Number($("#pageIdx").val()) + 1);

			goTransaction("saleCostListPageNo.do");
		});

		//前ページへ
		$("#underBackPage").click (function () {

			if ($("#pageIdx").val() == 0) {
				alert("先頭ページです");
				return;
			}
			$("#pageIdx").val(Number($("#pageIdx").val()) - 1);
			goTransaction("saleCostListPageNo.do");
		});

		//20140403 安藤　ここから
		//先頭ページへ
		$("#underFirstPage").click (function () {

			if ($("#pageIdx").val() == 0) {
				alert("先頭ページです");
				return;
			}

			if ($("#pageIdx").val() == ($(this).text() - 1)) {

				return;

			}

			$("#pageIdx").val(0);
			goTransaction("saleCostListPageNo.do");
		});

		//最終ページへ
		$("#underLastPage").click (function () {

			var maxPage = new Number($(".slipPageNum").eq(0).text());
			if (Number($("#pageIdx").val()) + 1 >= maxPage) {
				alert("最終ページです");
				return;
			}

			if ($("#pageIdx").val() == ($(this).text() - 1)) {

				return;

			}

			$("#pageIdx").val(maxPage - 1);
			goTransaction("saleCostListPageNo.do");
		});

		// 一括編集ボタン
		$(".editCostlist").click (function (){


			goTransaction("editsaleCost.do");

			return;
		});

//******************************************************************************************************
		$(".search").click (function () {

			if ($("#orderDateFrom").val() && $("#orderDateTo").val()){
				fromAry = $("#orderDateFrom").val().split("/");
				toAry = $("#orderDateTo").val().split("/");
				fromDt = new Date(fromAry[0], fromAry[1], fromAry[2]);
				toDt = new Date(toAry[0], toAry[1], toAry[2]);
				if (fromDt > toDt) {
					alert("注文日 の検索開始日付が、検索終了日付より後の日付になっています。");
					return false;
				}
			}

			if ($("#sumClaimPriceFrom").val() && $("#sumClaimPriceTo").val()) {
				if ($("#sumClaimPriceFrom").val() > $("#sumClaimPriceTo").val()) {
					alert("請求額 の検索開始金額が、検索終了金額より大きい額になっています。");
					return false;
				}
			}

			if ($("#destinationAppointDateFrom").val() && $("#destinationAppointDateTo").val()){
				fromAry = $("#destinationAppointDateFrom").val().split("/");
				toAry = $("#destinationAppointDateTo").val().split("/");
				fromDt = new Date(fromAry[0], fromAry[1], fromAry[2]);
				toDt = new Date(toAry[0], toAry[1], toAry[2]);
				if (fromDt > toDt) {
					alert("配送指定日 の検索開始日付が、検索終了日付より後の日付になっています。");
					return false;
				}
			}

			if ($("#shipmentPlanDateFrom").val() && $("#shipmentPlanDateTo").val()){
				fromAry = $("#shipmentPlanDateFrom").val().split("/");
				toAry = $("#shipmentPlanDateTo").val().split("/");
				fromDt = new Date(fromAry[0], fromAry[1], fromAry[2]);
				toDt = new Date(toAry[0], toAry[1], toAry[2]);
				if (fromDt > toDt) {
					alert("出荷予定日 の検索開始日付が、検索終了日付より後の日付になっています。");
					return false;
				}
			}

			if ($("#itemCodeFrom").val() && $("#itemCodeTo").val()) {
				if ($("#itemCodeFrom").val() > $("#itemCodeTo").val()) {
					alert("品番 の出力開始番号が、出力終了番号より大きい値になっています。");
					return false;
				}
			}

			$(".overlay").css("display", "block");
			$(".message").text("検索中");
			removeCommaList($(".priceTextMinus"));
			removeCommaGoTransaction('saleCostList.do');

		});

        $(window).keydown(function(event){
            if(event.keyCode == 13) {
	            event.preventDefault();
				if ($("#orderDateFrom").val() && $("#orderDateTo").val()){
					fromAry = $("#orderDateFrom").val().split("/");
					toAry = $("#orderDateTo").val().split("/");
					fromDt = new Date(fromAry[0], fromAry[1], fromAry[2]);
					toDt = new Date(toAry[0], toAry[1], toAry[2]);
					if (fromDt > toDt) {
						alert("注文日 の検索開始日付が、検索終了日付より後の日付になっています。");
						return false;
					}
				}
	
				if ($("#sumClaimPriceFrom").val() && $("#sumClaimPriceTo").val()) {
					if ($("#sumClaimPriceFrom").val() > $("#sumClaimPriceTo").val()) {
						alert("請求額 の検索開始金額が、検索終了金額より大きい額になっています。");
						return false;
					}
				}
	
				if ($("#destinationAppointDateFrom").val() && $("#destinationAppointDateTo").val()){
					fromAry = $("#destinationAppointDateFrom").val().split("/");
					toAry = $("#destinationAppointDateTo").val().split("/");
					fromDt = new Date(fromAry[0], fromAry[1], fromAry[2]);
					toDt = new Date(toAry[0], toAry[1], toAry[2]);
					if (fromDt > toDt) {
						alert("配送指定日 の検索開始日付が、検索終了日付より後の日付になっています。");
						return false;
					}
				}
	
				if ($("#shipmentPlanDateFrom").val() && $("#shipmentPlanDateTo").val()){
					fromAry = $("#shipmentPlanDateFrom").val().split("/");
					toAry = $("#shipmentPlanDateTo").val().split("/");
					fromDt = new Date(fromAry[0], fromAry[1], fromAry[2]);
					toDt = new Date(toAry[0], toAry[1], toAry[2]);
					if (fromDt > toDt) {
						alert("出荷予定日 の検索開始日付が、検索終了日付より後の日付になっています。");
						return false;
					}
				}
	
				if ($("#itemCodeFrom").val() && $("#itemCodeTo").val()) {
					if ($("#itemCodeFrom").val() > $("#itemCodeTo").val()) {
						alert("品番 の出力開始番号が、出力終了番号より大きい値になっています。");
						return false;
					}
				}
	
				$(".overlay").css("display", "block");
				$(".message").text("検索中");
				removeCommaList($(".priceTextMinus"));
				removeCommaGoTransaction('saleCostList.do');
            }
        });

	});

	var count;
	function boxChecked(check) {
	  	for(count= 0; count < document.saleForm.pickingFinBox.length; count++) {
	  		document.saleForm.pickingFinBox[count].checked = check;
	  	}
	  }


	</script>
	</head>
	<jsp:include page="/WEB-INF/page/common/menu.jsp" />
	<html:form action="/initSaleCostList" enctype="multipart/form-data">
	<html:hidden property="alertType" styleId="alertType"></html:hidden>

	<h4 class="headingKind">売上原価入力</h4>

	<fieldset id="searchOptionField">
	<legend id="searchOptionOpen">▲隠す</legend>
	<div id="searchOptionArea">
	<nested:nest property="saleCostSearchDTO" >
		<table id="checkBoxTable" style="border-collapse: collapse;">
			<tr>
				<td colspan="2" class="flgCheck"><label><nested:checkbox property="pickingListFlg"/>ピッキングリスト出力済</label></td>
				<td class="arrow">→</td>
				<td class="flgCheck"><label><nested:checkbox property="leavingFlg"/>出庫済</label></td>
				<td class="pdg_left_30px"><label><nested:checkbox property="returnFlg"/>返品伝票</label></td>
			</tr>
			<tr>
				<td><label><nested:checkbox property="searchAllFlg" />全件表示</label></td>
				<td class="td_right slipNoLabel">伝票番号</td>
				<td class="slipNoCheckBoxTd"><label><nested:checkbox property="slipNoExist" styleClass="slipNoCheckBox slipNoExist" />有</label></td>
				<td class="slipNoCheckBoxTd"><label><nested:checkbox property="slipNoHyphen" styleClass="slipNoCheckBox slipNoHyphen" />ハイフン</label></td>
				<td class="slipNoNoneCheckBoxTd"><label><nested:checkbox property="slipNoNone" styleClass="slipNoCheckBox slipNoNone" />無</label></td>
				<td></td>
			</tr>
		</table>

		<table id="rootTable" style="border-collapse: collapse;">
			<tr>
				<td>法人</td>
				<td colspan="3"><nested:select property="sysCorporationId">
						<html:option value="0">　</html:option>
						<html:optionsCollection property="corporationList" label="corporationNm" value="sysCorporationId" />
					</nested:select>
				</td>
				<td class="td_center">処理ルート</td>
				<td ><nested:select property="disposalRoute">
						<html:optionsCollection property="disposalRouteMap" label="value" value="key"/>
					</nested:select>
				</td>
			</tr>
			<tr>
				<td>販売チャネル</td>
				<td class="slipNoCheckBoxLeftTd"><label><nested:checkbox property="sysChannelIdOne" styleClass="slipNoCheckBox slipNoExist" />直営店</label></td>
				<td class="slipNoCheckBoxTd"><label><nested:checkbox property="sysChannelIdTwo" styleClass="slipNoCheckBox slipNoHyphen" />直営店2</label></td>
				<td class="slipNoNoneCheckBoxTd"><label><nested:checkbox property="sysChannelIdOther" styleClass="slipNoCheckBox slipNoNone" />その他</label></td>
			</tr>
		</table>

		<table id="costTable">
			<tr>
				<td>原価</td>
				<td><label><nested:checkbox property="costMakerItemFlg"/>メーカー品</label></td>
				<td><label><nested:checkbox property="costNoRegistry"/>原価未入力</label></td>
				<td><label><nested:checkbox property="costZeroRegistry"/>原価が0円</label></td>
			</tr>
			<tr>
				<td>原価確認</td>
				<td><label><nested:checkbox property="costNoCheckFlg"/>未確認</label></td>
				<td><label><nested:checkbox property="costCheckedFlg"/>確認済</label></td>
			</tr>
		</table>

		<table id="orderTable">
			<tr>
				<td>注文日</td>
				<td><nested:text property="orderDateFrom" styleId="orderDateFrom" styleClass="calender" maxlength="10" /> ～ <nested:text property="orderDateTo" styleId="orderDateTo" styleClass="calender" maxlength="10" /></td>
			</tr>
			<tr>
				<td>受注番号</td>
				<td><nested:text property="orderNo" styleClass="text_w250" maxlength="30" /></td>
			</tr>
			<tr>
				<td >
					<nested:select property="orderType">
						<html:option value="1">注文者名</html:option>
						<html:option value="2">お届先名</html:option>
					</nested:select>
				</td>
			
				<td><nested:text property="orderContent" styleClass="text_w250" maxlength="30" /></td>
			</tr>
			<tr>
				<td>一言メモ</td>
				<td><nested:text property="memo" styleClass="text_w250" /><br/><span class="explain">※BO情報やYahooID等</span></td>
			</tr>
		</table>

		<div id="centerArea">

		<table id="deliveryTable">
			<tr>
				<td>出荷予定日</td>
				<td><nested:text property="shipmentPlanDateFrom" styleId="shipmentPlanDateFrom" styleClass="calender" maxlength="10" /> ～ <nested:text property="shipmentPlanDateTo" styleId="shipmentPlanDateTo" styleClass="calender" maxlength="10" /></td>
			</tr>
		</table>

		<table id="destinationTable">
			<tr>
				<td>届け先名</td>
				<td><nested:text property="destinationNm" styleClass="text_w150" maxlength="30" /></td>
			</tr>
			<tr>
				<td>届け先TEL</td>
				<td><nested:text property="destinationTel" styleClass="text_w150" maxlength="13" /></td>
			</tr>
		</table>

		</div>

		<table id="itemTable">
			<tr>
				<td>品番（前方一致）</td>
				<td><nested:text property="itemCode" styleClass="text_w120 numText" maxlength="11" /></td>
			</tr>
			<tr>
				<td>他社品番（部分一致）</td>
				<td><nested:text property="salesItemCode" styleClass="text_w120" maxlength="30" /></td>
			</tr>
			<tr>
				<td>商品名</td>
				<td><nested:text property="itemNm" styleClass="text_w200" /></td>
			</tr>
			<tr>
				<td>他社商品名</td>
				<td><nested:text property="salesItemNm" styleClass="text_w200" /></td>
			</tr>
			<tr>
				<td>問屋名</td>
				<td><nested:text property="wholseSalerName" styleClass="text_w200" /></td>
			</tr>
		</table>

		<table id="buttonTable">
			<tr>
				<td>並び順</td>
				<td>
					<nested:select property="sortFirst" styleId="sortFirst">
						<html:optionsCollection property="saleSearchMap" value="key" label="value" />
					</nested:select>
					<nested:select property="sortFirstSub" styleId="sortFirstSub">
						<html:optionsCollection property="saleSearchSortOrder" value="key" label="value" />
					</nested:select>
				</td>
			</tr>
			<tr>
				<td>表示件数</td>
				<td>
					<nested:select property="listPageMax">
						<html:optionsCollection property="salelistPageMaxMap" value="key" label="value" />
					</nested:select>&nbsp;件
				</td>
			</tr>
			<tr>
				<td colspan="2" style="padding: 10px 0 0 60px;"><a class="button_main search" href="javascript:void(0);" >検索</a></td>
				<td colspan="2" style="padding-top: 14px;"><a class="button_white clear" href="javascript:void(0);">リセット</a></td>
			</tr>
		</table>

	</nested:nest>
	</div>
	</fieldset>
	<nested:nest property="errorDTO">
	<nested:notEmpty property="errorMessage">
		<div id="errorArea">
			<p class="errorMessage"><nested:write property="errorMessage"/></p>
		</div>
	</nested:notEmpty>
	</nested:nest>

	<nested:notEmpty property="salesCostList">
	<div class="middleArea">
		<table class="editButtonTable">
			<tr>
				<td><a class="button_main editCostlist" href="Javascript:void(0);">一括編集する</a></td>
			</tr>
		</table>
	</div>



<!-- ページ(上側) -->

	<div class="paging_area">
		<div class="paging_total_top">
			<h3>全&nbsp;<nested:write property="sysSaleItemIDListSize" />&nbsp;件&nbsp;（&nbsp;<span class="slipNowPage" ></span>&nbsp;/&nbsp;<span class="slipPageNum"></span>&nbsp;ページ&nbsp;）</h3>
		</div>
		<div class="paging_num_top">
			<ul class="pager fr mb10">
			    <li class="backButton"><a href="javascript:void(0);" id="backPage" >&laquo;</a></li>
			    <li class="liFirstPage" ><a href="javascript:void(0);" id="firstPage" >1</a></li>
			    <li class="3dotLineTop"><span>...</span></li>
				<li><a href="javascript:void(0);" class="pageNum" ></a></li>
			  	<li class="3dotLineEnd"><span>...</span></li>
			    <li class="liLastPage" ><a href="javascript:void(0);" id="lastPage"  class="lastIdx" ></a></li>
			    <li class="nextButton"><a href="javascript:void(0);" id="nextPage" >&raquo;</a></li>
			</ul>
		</div>


<!-- ページ(上側)ここまで -->
	</div>

	<div id="list_area" >
	<input type="hidden" name="sysSalesSlipId" id="sysSalesSlipId" />
	<input type="hidden" name="sysSalesIndex" id="sysSalesIndex" />
	<nested:hidden property="sysSaleItemIDListSize" styleId="sysSaleItemIDListSize" />
	<nested:hidden property="saleCostPageIdx" styleId="pageIdx" />
	<nested:hidden property="saleListPageMax" styleId="saleListPageMax" />
	<nested:hidden property="saleCostListIdx" styleId="listIdx" />
	
		<table class="list_table">
			<tr>
				<th class="saleSlipNo">伝票番号</th>
				<th class="corporationNm">取引先法人</th>
				<th class="shipmentPlanDate">出庫予定日</th>
				<th class="itemCode">品番</th>
				<th class="itemNm">商品名</th>
				<th class="orderNm">注文数</th>
				<th class="pieceRate">単価</th>
				<th class="corporationRateOverHd">法人掛け率</th>
				<th class="cost">原価(メーカー)</th>
				<th class="kindCost">Kind原価</th>
				<th class="domePostage">送料</th>
				<th class="listPrice">定価</th>
				<th class="itemRateOver">商品掛け率</th>
				<th class="calcHd">入力した定価で<br />金額算出
				</th>
				<th class="reflectHd">直近の原価を<br />反映
				</th>
				<th class="profit">利益判定</th>
				<th class="check">確認</th>
				<th class="saveHd">編集</th>
			</tr>

			<nested:iterate property="salesCostList" indexId="idx">

<!-- 		マスタにない商品 -->
			<nested:notEqual property="sysItemId" value="0">
				<bean:define id="backgroundColor" value="" />
			</nested:notEqual>
			<nested:equal property="sysItemId" value="0">
				<bean:define id="backgroundColor" value="#FFFFC0" />
			</nested:equal>

			<tbody style="background:${backgroundColor};" class="salesSlipRow change_color">
			<nested:hidden property="sysSalesSlipId" styleClass="sysSalesSlipId"></nested:hidden>
			<nested:hidden property="sysSalesItemId" styleClass="sysSalesItemId" />
			<nested:hidden property="storeFlag"	styleClass="storeFlag" />
			
			<tr>
				<td>
					<a href="Javascript:(void);" class="salesSlipLink" >
						<nested:write property="saleSlipNo" />
						<nested:hidden property="sysSalesSlipId" styleClass="sysSalesSlipId_Link"></nested:hidden>
					</a>
				</td>
				<td><nested:write property="corporationNm" /></td>
				<td><nested:write property="shipmentPlanDate" /></td>
				<td>
					<a href="Javascript:(void);" class="itemCodeLink" >
						<nested:write property="itemCode" />
						<input type="hidden" name="managementCode" id="managementCode">
						<nested:hidden property="itemCode" styleClass="itemCode"></nested:hidden>
					</a>
				
				</td>
				<td><nested:write property="itemNm" /></td>
				<td><nested:write property="orderNum" /></td>
				<td class="pieceRateEdit"><nested:write property="pieceRate" format="###,###,###" />&nbsp;円</td>
				<td class="corporationRateOverEdit"><nested:write property="corporationRateOver" />&nbsp;％</td>
				<td class="costEdit"><nested:write property="cost" format="###,###,###" />&nbsp;円</td>
				<td class="kindCostEdit"><nested:write property="kindCost" format="###,###,###" />&nbsp;円</td>
				<td class="domePostageEdit"><nested:write property="domePostage" format="###,###,###" />&nbsp;円</td>
				<td class="listPriceEdit"><nested:write property="listPrice" format="###,###,###" />&nbsp;円</td>
				<td class="itemRateOverEdit"><nested:write property="itemRateOver" />&nbsp;％</td>
				<td class="tdButton"><button type="button"
					class="button_small_main calcSaleCost" disabled>算出</button></td>
				<td class="tdButton"><button type="button"
					class="button_small_main reflectLatestSaleCostCost" disabled>反映</button></td>
				<td class="profitId"><nested:write property="profit" />&nbsp;円</td>
				<td class="costCheck"><nested:checkbox property="costCheckFlag" disabled="true" /></td>
				<td class="tdButton"><button type="button"
					class="button_small_main saleCostEdit" >編集</button></td>
			</tr>
			</tbody>
			</nested:iterate>
			</table>
		</div>

<!-- ページ(下側) 20140407 安藤 -->
		<div class="under_paging_area">
			<div class="paging_total_top">
				<h3>全&nbsp;<nested:write property="sysSaleItemIDListSize" />&nbsp;件&nbsp;（&nbsp;<span class="slipNowPage" ></span>&nbsp;/&nbsp;<span class="slipPageNum"></span>&nbsp;ページ&nbsp;）</h3>
			</div>
			<div class="paging_num_top">
				<ul class="pager fr mb10 underPager">
				    <li class="backButton"><a href="javascript:void(0);" id="underBackPage" >&laquo;</a></li>
				    <li class="liFirstPage" ><a href="javascript:void(0);" id="underFirstPage" >1</a></li>
				    <li class="3dotLineTop"><span>...</span></li>
					<li><a href="javascript:void(0);" class="pageNum" ></a></li>
				  	<li class="3dotLineEnd"><span>...</span></li>
				    <li class="liLastPage" ><a href="javascript:void(0);" id="underLastPage"  class="lastIdx" ></a></li>
				    <li class="nextButton"><a href="javascript:void(0);" id="underNextPage" >&raquo;</a></li>
				</ul>
			</div>
		</div>
<!-- ページ(下側)　ここまで -->

		</nested:notEmpty>


	</html:form>
	<div class="overlay">
		<div class="messeage_box">
			<h1 class="message">ファイル作成中</h1>
			<BR />
			<p>Now Loading...</p>
			<img  src="./img/load.gif" alt="loading" ></img>
				<BR />
				<BR />
				<BR />
		</div>
	</div>
</html:html>
