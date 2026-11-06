using ModernWMS.WMS.Entities.ViewModels;
using ModernWMS.Core.Services;
using ModernWMS.WMS.Entities.Models;

namespace ModernWMS.WMS.IServices;

/// <summary>Service contract for approval-flow map assembly.</summary>
public interface IFlowSetService : IBaseService<FlowSetEntity>
{
    Task<FlowSetMapGetViewModel> GetFlowSetMap(int id);
}
