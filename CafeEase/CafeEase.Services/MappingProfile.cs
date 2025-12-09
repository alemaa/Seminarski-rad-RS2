using AutoMapper;
using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Services.Database;

namespace CafeEase.Services.Mapping
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<Database.User, Model.User>();
            CreateMap<Model.Requests.UserInsertRequest, Database.User>();
            CreateMap<Model.Requests.UserUpdateRequest, Database.User>();
            CreateMap<Database.Category, Model.Category>();
            CreateMap<CategoryUpsertRequest, Database.Category>();
            CreateMap<Database.Product, Model.Product>();
            CreateMap<ProductInsertRequest, Database.Product>();
            CreateMap<ProductUpdateRequest, Database.Product>();
            CreateMap<OrderInsertRequest, Database.Order>();
            CreateMap<Database.Order, Model.Order>();
            CreateMap<Database.OrderItem, Model.OrderItem>();
            CreateMap<OrderItemInsertRequest, Database.OrderItem>();
            CreateMap<OrderItemUpdateRequest, Database.OrderItem>();
            CreateMap<Database.Payment, Model.Payment>();
            CreateMap<PaymentInsertRequest, Database.Payment>();
            CreateMap<PaymentUpdateRequest, Database.Payment>();
            CreateMap<Database.LoyaltyPoints, Model.LoyaltyPoints>();
            CreateMap<LoyaltyPointsInsertRequest, Database.LoyaltyPoints>();
            CreateMap<LoyaltyPointsUpdateRequest, Database.LoyaltyPoints>();
            CreateMap<Database.Promotion, Model.Promotion>();
            CreateMap<PromotionInsertRequest, Database.Promotion>();
            CreateMap<PromotionUpdateRequest, Database.Promotion>();

        }
    }
}