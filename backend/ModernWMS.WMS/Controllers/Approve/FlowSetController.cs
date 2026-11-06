using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ModernWMS.Core.Controller;
using ModernWMS.Core.DBContext;
using ModernWMS.Core.Models;
using ModernWMS.WMS.Entities.Models;
using ModernWMS.WMS.Entities.Models.Approve;
using ModernWMS.WMS.Entities.ViewModels;
using ModernWMS.WMS.Entities.ViewModels.Approve;
using ModernWMS.WMS.IServices;

namespace ModernWMS.WMS.Controllers;

/// <summary>
/// Approval-flow configuration endpoints. These endpoints manage the flow
/// definition; transaction-specific approval execution is still owned by the
/// business operation that uses the definition.
/// </summary>
[Route("approve/flowset")]
[ApiController]
[ApiExplorerSettings(GroupName = "Base")]
public class FlowSetController : BaseController
{
    private readonly SqlDBContext _db;
    private readonly IFlowSetService _flowSetService;

    public FlowSetController(SqlDBContext db, IFlowSetService flowSetService)
    {
        _db = db;
        _flowSetService = flowSetService;
    }

    /// <summary>Lists flow definitions for the current tenant.</summary>
    [HttpGet]
    public async Task<ResultModel<List<FlowSetMainEntity>>> List()
    {
        var rows = await _db.Set<FlowSetMainEntity>()
            .AsNoTracking()
            .Where(t => t.tenant_id == CurrentUser.tenant_id)
            .OrderByDescending(t => t.create_time)
            .ToListAsync();
        return ResultModel<List<FlowSetMainEntity>>.Success(rows);
    }

    /// <summary>Returns the nested approval map for one flow definition.</summary>
    [HttpGet("{id:int}/map")]
    public async Task<ResultModel<FlowSetMapGetViewModel>> GetMap(int id)
    {
        var main = await _db.Set<FlowSetMainEntity>()
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.id == id && t.tenant_id == CurrentUser.tenant_id);
        if (main == null)
        {
            return ResultModel<FlowSetMapGetViewModel>.Error("not_exists_entity");
        }

        var map = await _flowSetService.GetFlowSetMap(id);
        return ResultModel<FlowSetMapGetViewModel>.Success(map);
    }

    /// <summary>
    /// Creates a flow definition and its nodes, approvers, and conditions.
    /// IDs supplied by clients are ignored so a fixture cannot overwrite an
    /// existing tenant's workflow.
    /// </summary>
    [HttpPost]
    public async Task<ResultModel<int>> Create(FlowSetCreateRequest input)
    {
        if (string.IsNullOrWhiteSpace(input.menu) || string.IsNullOrWhiteSpace(input.flow_name))
        {
            return ResultModel<int>.Error("menu_and_flow_name_required");
        }

        var main = new FlowSetMainEntity
        {
            menu = input.menu.Trim(),
            flow_name = input.flow_name.Trim(),
            creator = CurrentUser.user_name,
            create_time = DateTime.Now,
            tenant_id = CurrentUser.tenant_id
        };
        await _db.Set<FlowSetMainEntity>().AddAsync(main);
        await _db.SaveChangesAsync();

        foreach (var node in input.nodes ?? new List<FlowSetNodeRequest>())
        {
            var savedNode = new FlowSetEntity
            {
                flowsetmain_id = main.id,
                is_origin = node.is_origin,
                is_end = node.is_end,
                node_guid = node.node_guid,
                node_name = node.node_name,
                prev_node_guid = node.prev_node_guid
            };
            await _db.Set<FlowSetEntity>().AddAsync(savedNode);
            await _db.SaveChangesAsync();

            foreach (var user_id in node.user_ids ?? new List<int>())
            {
                await _db.Set<FlowSetUserEntity>().AddAsync(new FlowSetUserEntity
                {
                    flowset_id = savedNode.id,
                    flowsetmain_id = main.id,
                    node_guid = savedNode.node_guid,
                    user_id = user_id
                });
            }

            foreach (var condition in node.conditions ?? new List<FlowSetConditionViewModel>())
            {
                await _db.Set<FlowSetFilterEntity>().AddAsync(new FlowSetFilterEntity
                {
                    flowset_id = savedNode.id,
                    flowsetmain_id = main.id,
                    node_guid = savedNode.node_guid,
                    logic = condition.logic,
                    c1 = condition.c1,
                    col_label = condition.col_label,
                    col_name = condition.col_name,
                    compare = condition.compare,
                    content = condition.content,
                    c2 = condition.c2,
                    sort = condition.sort,
                    condition_group = condition.condition_group,
                    formulas = condition.formulas,
                    assert_mode = condition.assert_mode,
                    table_name = condition.table_name,
                    scheme_name = condition.scheme_name
                });
            }
        }
        await _db.SaveChangesAsync();
        return ResultModel<int>.Success(main.id);
    }

    /// <summary>Deletes one flow definition and only its child records.</summary>
    [HttpDelete("{id:int}")]
    public async Task<ResultModel<bool>> Delete(int id)
    {
        var main = await _db.Set<FlowSetMainEntity>()
            .FirstOrDefaultAsync(t => t.id == id && t.tenant_id == CurrentUser.tenant_id);
        if (main == null)
        {
            return ResultModel<bool>.Error("not_exists_entity");
        }

        var nodes = await _db.Set<FlowSetEntity>().Where(t => t.flowsetmain_id == id).ToListAsync();
        var nodeIds = nodes.Select(t => t.id).ToList();
        _db.Set<FlowSetUserEntity>().RemoveRange(await _db.Set<FlowSetUserEntity>().Where(t => nodeIds.Contains(t.flowset_id)).ToListAsync());
        _db.Set<FlowSetFilterEntity>().RemoveRange(await _db.Set<FlowSetFilterEntity>().Where(t => nodeIds.Contains(t.flowset_id)).ToListAsync());
        _db.Set<FlowSetEntity>().RemoveRange(nodes);
        _db.Set<FlowSetMainEntity>().Remove(main);
        await _db.SaveChangesAsync();
        return ResultModel<bool>.Success(true);
    }
}

/// <summary>Input contract intentionally excludes EF navigation properties.</summary>
public sealed class FlowSetCreateRequest
{
    public string menu { get; set; } = string.Empty;
    public string flow_name { get; set; } = string.Empty;
    public List<FlowSetNodeRequest> nodes { get; set; } = new();
}

public sealed class FlowSetNodeRequest
{
    public bool is_origin { get; set; }
    public bool is_end { get; set; }
    public string node_guid { get; set; } = string.Empty;
    public string node_name { get; set; } = string.Empty;
    public string prev_node_guid { get; set; } = string.Empty;
    public List<int> user_ids { get; set; } = new();
    public List<FlowSetConditionViewModel> conditions { get; set; } = new();
}
