using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using ModernWMS.Core.DBContext;
using ModernWMS.Core.JWT;
using ModernWMS.Core.Utility;
using ModernWMS.WMS.Entities.Models;
using System.Text.Json;

namespace ModernWMS.WMS.Middleware;

/// <summary>
/// Enforces the action authorities already maintained by the role-menu UI.
/// Reads remain available to authenticated users; write actions require the
/// matching action code in the role's menu assignment.
/// </summary>
public sealed class WmsActionAuthorizationFilter : IAsyncActionFilter
{
    private static readonly IReadOnlyDictionary<string, string> MenuByController =
        new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["Company"] = "companySetting",
            ["Userrole"] = "userRoleSetting",
            ["Rolemenu"] = "roleMenu",
            ["User"] = "userManagement",
            ["Category"] = "commodityCategorySetting",
            ["Spu"] = "commodityManagement",
            ["Supplier"] = "supplier",
            ["Warehouse"] = "warehouseSetting",
            ["Warehousearea"] = "warehouseSetting",
            ["Goodslocation"] = "warehouseSetting",
            ["Goodsowner"] = "ownerOfCargo",
            ["Freightfee"] = "freightSetting",
            ["Customer"] = "customer",
            ["Stock"] = "stockManagement",
            ["Stockprocess"] = "warehouseProcessing",
            ["Stockmove"] = "warehouseMove",
            ["Stockfreeze"] = "warehouseFreeze",
            ["Stockadjust"] = "warehouseAdjust",
            ["Stocktaking"] = "warehouseTaking",
            ["Asn"] = "stockAsn",
            ["Dispatchlist"] = "deliveryManagement",
            ["PrintSolution"] = "print"
        };

    private readonly SqlDBContext _db;

    public WmsActionAuthorizationFilter(SqlDBContext db)
    {
        _db = db;
    }

    public async Task OnActionExecutionAsync(
        ActionExecutingContext context,
        ActionExecutionDelegate next)
    {
        var request = context.HttpContext.Request;
        if (HttpMethods.IsGet(request.Method) ||
            HttpMethods.IsHead(request.Method) ||
            HttpMethods.IsOptions(request.Method) ||
            context.HttpContext.GetEndpoint()?.Metadata.GetMetadata<AllowAnonymousAttribute>() != null)
        {
            await next();
            return;
        }

        if (context.ActionDescriptor is not Microsoft.AspNetCore.Mvc.Controllers.ControllerActionDescriptor descriptor)
        {
            await next();
            return;
        }

        var controller = descriptor.ControllerName;
        var currentUser = ReadCurrentUser(context.HttpContext);
        if (controller.Equals("FlowSet", StringComparison.OrdinalIgnoreCase))
        {
            // This endpoint has no legacy menu row yet. Until it is registered
            // in the permission model, restrict configuration to administrators.
            if (currentUser.userrole_id != 1)
            {
                context.Result = new StatusCodeResult(StatusCodes.Status403Forbidden);
                return;
            }

            await next();
            return;
        }

        if (controller.Equals("Rolemenu", StringComparison.OrdinalIgnoreCase))
        {
            // Role-menu administration changes the permission model itself.
            // The upstream menu registry intentionally exposes no ordinary
            // action code for it, so keep it administrator-only.
            if (currentUser.userrole_id != 1)
            {
                context.Result = new StatusCodeResult(StatusCodes.Status403Forbidden);
                return;
            }

            await next();
            return;
        }

        // The bundled administrator role is the product's break-glass role.
        // Preserve that documented behavior explicitly; custom roles still
        // go through the menu/action checks below.
        if (currentUser.userrole_id == 1)
        {
            await next();
            return;
        }

        if (!MenuByController.TryGetValue(controller, out var menuCode))
        {
            // New controllers must opt into the registry before their write
            // actions can mutate WMS data.
            context.Result = new StatusCodeResult(StatusCodes.Status403Forbidden);
            return;
        }

        var actionCode = ResolveActionCode(controller, descriptor.ActionName, request.Method);
        if (string.IsNullOrEmpty(actionCode))
        {
            await next();
            return;
        }

        var menu = await _db.Set<MenuEntity>()
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.vue_path == menuCode && t.tenant_id == currentUser.tenant_id);
        if (menu == null)
        {
            context.Result = new StatusCodeResult(StatusCodes.Status403Forbidden);
            return;
        }

        var roleMenu = await _db.Set<RolemenuEntity>()
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.userrole_id == currentUser.userrole_id &&
                                      t.menu_id == menu.id &&
                                      t.tenant_id == currentUser.tenant_id);
        if (roleMenu == null || roleMenu.authority == 0 ||
            !ContainsAction(roleMenu.menu_actions_authority, actionCode))
        {
            context.Result = new StatusCodeResult(StatusCodes.Status403Forbidden);
            return;
        }

        await next();
    }

    private static CurrentUser ReadCurrentUser(HttpContext context)
    {
        var claim = context.User.Claims.FirstOrDefault(t => t.Type == ClaimValueTypes.Json);
        if (claim == null)
        {
            return new CurrentUser();
        }
        return JsonHelper.DeserializeObject<CurrentUser>(claim.Value) ?? new CurrentUser();
    }

    private static bool ContainsAction(string json, string actionCode)
    {
        try
        {
            var actions = JsonSerializer.Deserialize<List<string>>(json ?? "[]") ?? new();
            return actions.Contains(actionCode, StringComparer.OrdinalIgnoreCase);
        }
        catch (JsonException)
        {
            return false;
        }
    }

    private static string ResolveActionCode(string controller, string actionName, string method)
    {
        if (controller.Equals("Warehouse", StringComparison.OrdinalIgnoreCase))
        {
            if (actionName.Equals("ExcelAsync", StringComparison.OrdinalIgnoreCase))
                return "warehouse-import";
            if (actionName.Equals("AddAsync", StringComparison.OrdinalIgnoreCase) ||
                actionName.Equals("UpdateAsync", StringComparison.OrdinalIgnoreCase))
                return "warehouse-save";
            if (actionName.Equals("DeleteAsync", StringComparison.OrdinalIgnoreCase))
                return "warehouse-delete";
        }
        if (controller.Equals("Warehousearea", StringComparison.OrdinalIgnoreCase))
        {
            if (actionName.Equals("AddAsync", StringComparison.OrdinalIgnoreCase) ||
                actionName.Equals("UpdateAsync", StringComparison.OrdinalIgnoreCase))
                return "area-save";
            if (actionName.Equals("DeleteAsync", StringComparison.OrdinalIgnoreCase))
                return "area-delete";
        }
        if (controller.Equals("Goodslocation", StringComparison.OrdinalIgnoreCase))
        {
            if (actionName.Equals("AddAsync", StringComparison.OrdinalIgnoreCase) ||
                actionName.Equals("UpdateAsync", StringComparison.OrdinalIgnoreCase))
                return "location-save";
            if (actionName.Equals("DeleteAsync", StringComparison.OrdinalIgnoreCase))
                return "location-delete";
        }

        if (controller.Equals("Stockmove", StringComparison.OrdinalIgnoreCase) &&
            actionName.Equals("Confirm", StringComparison.OrdinalIgnoreCase))
            return "confirm";
        if (controller.Equals("Stockprocess", StringComparison.OrdinalIgnoreCase) &&
            actionName.Equals("ConfirmProcess", StringComparison.OrdinalIgnoreCase))
            return "confirmOpeartion";
        if (controller.Equals("Stockprocess", StringComparison.OrdinalIgnoreCase) &&
            actionName.Equals("ConfirmAdjustment", StringComparison.OrdinalIgnoreCase))
            return "confirmAdjust";
        if (controller.Equals("Stocktaking", StringComparison.OrdinalIgnoreCase) &&
            actionName.Equals("ConfirmAsync", StringComparison.OrdinalIgnoreCase))
            return "confirmAdjust";
        if (controller.Equals("Stocktaking", StringComparison.OrdinalIgnoreCase) &&
            actionName.Equals("PutAsync", StringComparison.OrdinalIgnoreCase))
            return "confirmOpeartion";
        if (controller.Equals("Stockadjust", StringComparison.OrdinalIgnoreCase) &&
            actionName.Equals("ConfirmAdjustment", StringComparison.OrdinalIgnoreCase))
            return "confirmAdjust";
        if (controller.Equals("Stockfreeze", StringComparison.OrdinalIgnoreCase))
        {
            if (actionName.Equals("AddAsync", StringComparison.OrdinalIgnoreCase))
                return "freeze";
            if (actionName.Equals("UpdateAsync", StringComparison.OrdinalIgnoreCase))
                return "unfreeze";
        }
        if (controller.Equals("Spu", StringComparison.OrdinalIgnoreCase) &&
            actionName.Equals("InsertOrUpdateSkuSafetyStockAsync", StringComparison.OrdinalIgnoreCase))
            return "saftyStock";

        if (controller.Equals("Asn", StringComparison.OrdinalIgnoreCase))
        {
            if (actionName.Contains("Asnmaster", StringComparison.OrdinalIgnoreCase))
                return actionName.Contains("Delete", StringComparison.OrdinalIgnoreCase) ? "notice-delete" : "notice-save";
            if (actionName.Equals("AddAsync", StringComparison.OrdinalIgnoreCase) ||
                actionName.Equals("UpdateAsync", StringComparison.OrdinalIgnoreCase))
                return "notice-save";
            if (actionName.Equals("DeleteAsync", StringComparison.OrdinalIgnoreCase))
                return "notice-delete";
            if (actionName.Equals("ConfirmAsync", StringComparison.OrdinalIgnoreCase) ||
                actionName.Equals("ConfirmCancelAsync", StringComparison.OrdinalIgnoreCase))
                return "delivered-confirm";
            if (actionName.Equals("UnloadAsync", StringComparison.OrdinalIgnoreCase) ||
                actionName.Equals("UnloadCancelAsync", StringComparison.OrdinalIgnoreCase))
                return "unloaded-confirm";
            if (actionName.Equals("SortingAsync", StringComparison.OrdinalIgnoreCase) ||
                actionName.Equals("ModifyAsnsortsAsync", StringComparison.OrdinalIgnoreCase))
                return "sorted-editCount";
            if (actionName.Equals("SortedAsync", StringComparison.OrdinalIgnoreCase) ||
                actionName.Equals("SortedCancelAsync", StringComparison.OrdinalIgnoreCase))
                return "sorted-confirm";
            if (actionName.Equals("PutAwayAsync", StringComparison.OrdinalIgnoreCase))
                return "putOnTheShelf-editArrival";
        }

        if (controller.Equals("Dispatchlist", StringComparison.OrdinalIgnoreCase))
        {
            var dispatchActions = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                ["ConfirmOrder"] = "invoice-confirm",
                ["ConfirmPickByDispatchNo"] = "picked-confirm",
                ["ConfirmPickDetail"] = "picked-confirm",
                ["CancelConfirmPickDetail"] = "picked-revoke",
                ["Package"] = "packaged-package",
                ["Weight"] = "weighed-weigh",
                ["Delivery"] = "delivered-delivery",
                ["SetFreightfee"] = "delivered-setCarrier",
                ["SignForArrival"] = "delivered-signIn",
                ["CancelOrderOpration"] = "invoice-revoke",
                ["CancelDispatchlistDetailOpration"] = "picked-revoke"
            };
            if (dispatchActions.TryGetValue(actionName, out var dispatchCode))
                return dispatchCode;
            if (actionName.Equals("AddAsync", StringComparison.OrdinalIgnoreCase) ||
                actionName.Equals("UpdateAsycn", StringComparison.OrdinalIgnoreCase))
                return "invoice-save";
            if (actionName.Equals("DeleteAsync", StringComparison.OrdinalIgnoreCase))
                return "invoice-delete";
            if (actionName.Equals("Import", StringComparison.OrdinalIgnoreCase))
                return "invoice-save";
        }

        if (actionName.Equals("ExcelAsync", StringComparison.OrdinalIgnoreCase) ||
            actionName.Contains("Import", StringComparison.OrdinalIgnoreCase))
            return "import";
        if (actionName.Equals("ResetPwd", StringComparison.OrdinalIgnoreCase))
            return "resetPwd";
        if (HttpMethods.IsDelete(method) || actionName.Contains("Delete", StringComparison.OrdinalIgnoreCase))
            return "delete";
        if (actionName.Contains("Add", StringComparison.OrdinalIgnoreCase) ||
            actionName.Contains("Create", StringComparison.OrdinalIgnoreCase) ||
            actionName.Contains("Update", StringComparison.OrdinalIgnoreCase))
            return "save";
        return string.Empty;
    }
}
