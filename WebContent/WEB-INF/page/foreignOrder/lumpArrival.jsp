<?xml version="1.0" encoding="UTF-8""?>
<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html:html>
	<head>
	<jsp:include page="/WEB-INF/page/define/define-meta.jsp" />
	<link rel="stylesheet" href="./css/lumpArrival.css" type="text/css" />
	<link rel="stylesheet" href="./css/jquery-ui-1.10.4.custom.min.css" type="text/css" />
	<link rel="stylesheet" href="./css/jquery-ui-1.10.4.custom.css" type="text/css" />
	<script src="./js/jquery-1.10.2.min.js" language="javascript"></script>
	<script src="./js/jquery-ui-1.10.4.custom.min.js" language="javascript"></script>

	<script src="./js/jquery.ui.core.min.js"></script>
	<script src="./js/jquery.ui.datepicker.min.js"></script>
	<script src="./js/jquery.ui.datepicker-ja.min.js"></script>

<!--
【一括入荷画面】
ファイル名：lumpArrival.jsp
作成日：2014/12/19
作成者：八鍬寛之

（画面概要）

・在庫一覧で検索された商品の入荷予定情報を表示し、
一括で在庫に反映することができる
・反映する倉庫と数は変更可能。もし全ての入荷数を反映させなかった場合は
そこで登録した分だけ入荷履歴に入り、残数はそのまま入荷予定データとして残る

・一括入荷ボタン押下：入力されている倉庫に入荷数分在庫を増やす。

（注意・補足）

-->
	</head>
	<jsp:include page="/WEB-INF/page/common/menu.jsp" />
	<html:form action="lumpArrival">
	<html:hidden property="messageFlg" styleId="messageFlgForm"/>

		<nested:nest property="registryDto">
			<nested:hidden property="messageFlg" styleId="messageFlg"/>
			<nested:notEmpty property="message">
				<div id="messageArea">
					<p class="registryMessage" style="text-align: center;"><nested:write property="message"/></p>
				</div>
			</nested:notEmpty>
		</nested:nest>

	<h4 class="heading">一括入荷画面</h4>

	<nested:notEmpty property="errorMessageDTO">
		<nested:nest property="errorMessageDTO">
			<nested:notEmpty property="errorMessage">
				<p id="errorMessage"><nested:write property="errorMessage" /></p>
			</nested:notEmpty>
		</nested:nest>
	</nested:notEmpty>

	<div id="list_area">
		<table id="list_table">
			<tr>
				<td colspan="4">
				<td>
					<html:select property="sysWarehouseId" styleClass="warehouseChangeAll" styleId="warehouseChangeAll">
						<html:option value=""></html:option>
						<html:optionsCollection property="warehouseList" label="warehouseNm" value="sysWarehouseId"/>
					</html:select>
				</td>
				<td colspan="4">
			</tr>
			<tr>
				<th class="index"></th>
				<th class="poNo">PoNo.</th>
				<th class="code">品番</th>
				<th class="itemNm">商品名</th>
				<th class="warehouse">倉庫</th>
				<th class="orderDate">注文日</th>
				<th class="scheduleDate">入荷予定日</th>
				<th class="scheduleNum">入荷予定数</th>
				<th class="updateNum">反映数</th>
			</tr>

			<nested:iterate property="lumpArrivalList" indexId="idx">
			<tr>
				<nested:hidden property="sysItemId"/>
				<td class="w20"><%= idx + 1 %></td>
				<td><nested:write property="poNo"/></td>
				<td><nested:write property="itemCode" /></td>
				<td><nested:write property="itemNm" /></td>
				<td><nested:select property="sysWarehouseId" styleClass="sysWarehouseId">
						<html:optionsCollection property="warehouseList" label="warehouseNm" value="sysWarehouseId"/>
					</nested:select>
				</td>
				<td><nested:write property="itemOrderDate"/></td>
				<td><nested:write property="arrivalScheduleDate"/></td>
				<td><nested:write property="arrivalScheduleNum"/></td>
				<td><nested:text property="arrivalNum" styleClass="num numText" maxlength="4" /></td>
			</tr>
			</nested:iterate>
		</table>
	</div>

	<div class="paging_area">
<!-- 		<div class="paging_total"> -->
<!-- 				<h3>全100件（1/8ページ）</h3> -->
<!-- 		</div> -->
<!-- 		<div class="paging_num"> -->
<!-- 			<ul class="pager fr mb10"> -->
<!-- 			    <li class="disabled"><a href="#">&laquo;</a></li> -->
<!-- 			    <li class="current"><span>1</span></li> -->
<!-- 			    <li><a href="javascript:void(0);" >2</a></li> -->
<!-- 			    <li><a href="javascript:void(0);" >3</a></li> -->
<!-- 			    <li><a href="javascript:void(0);" >4</a></li> -->
<!-- 			    <li><a href="javascript:void(0);" >5</a></li> -->
<!-- 			    <li><a href="javascript:void(0);" >6</a></li> -->
<!-- 			    <li><a href="javascript:void(0);" >7</a></li> -->
<!-- 			    <li><a href="javascript:void(0);" >8</a></li> -->
<!-- 			    <li><a href="javascript:void(0);" >&raquo;</a></li> -->
<!-- 			</ul> -->
<!-- 		</div> -->
		<div class="button_area">
			<ul style="position: relative;">
				<li class="footer_button">
					<a class="button_white" id="returnForeignOrderList" href="javascript:void(0);">一覧に戻る</a>
				</li>
				<li class="footer_button">
					<a class="button_main" href="Javascript:void(0);" id="lumpArrival">一括入荷</a>
				</li>
			</ul>
		</div>
	</div>

	</html:form>

	<script type="text/javascript">
	$(function() {
		$('.num').spinner( {
			max: 9999,
			min: 0,
			step: 1
		});

		$('#warehouseChangeAll').val("");

// 		var alertType = $("#alertType").val();
// 		if (alertType != null && alertType == "4") {
// 			alert("入荷しました。");
// 		}
// 		$("#alertType").val(0);

		$('#warehouseChangeAll').change(function() {

			if($('#warehouseChangeAll').val() == "") {
				return;
			}

			 $(".sysWarehouseId").each(function () {
				$(this).val($("#warehouseChangeAll").val());
			 });
		});

		//メッセージエリア表示設定
		if(!$("#registryDto.message").val()) {
			if ($("#messageFlg").val() == "0") {
				$("#messageArea").addClass("registrySuccess");
			}
			if ($("#messageFlg").val() == "1") {
				$("#messageArea").addClass("registryFailure");
			}
			$("#messageArea").fadeOut(4000);
		}

		//一括入荷ボタン押下
		$("#lumpArrival").click (function () {

// 			$(".sysWarehouseId").each(function () {

// 				if($(this).val($("#warehouseChangeAll").val() == "")) {
// 					alert("倉庫名を空白には出来ません");
// 					return false;
// 				}
// 			 });

			if (!confirm("在庫に反映させます。よろしいですか？")) {
				return;
			}

			goTransaction("lumpArrival.do");
		});

		//一覧に戻るボタン押下時の処理

		$("#returnForeignOrderList").click (function () {
			goTransaction('returnForeignOrderList.do');
		});
	});

	</script>
</html:html>