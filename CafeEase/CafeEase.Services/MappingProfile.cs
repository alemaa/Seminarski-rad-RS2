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
            CreateMap<Database.OrderItem, Model.OrderItem>().ForMember(dest => dest.ProductName, opt => opt.MapFrom(src => src.Product.Name));
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
            CreateMap<Database.Review, Model.Review>();
            CreateMap<ReviewInsertRequest, Database.Review>();
            CreateMap<ReviewUpdateRequest, Database.Review>();
            CreateMap<Database.Reservation, Model.Reservation>().ForMember(dest => dest.TableNumber, opt => opt.MapFrom(src => src.Table.Number)).
                ForMember(dest => dest.UserFullName, opt => opt.MapFrom(src => src.User != null ? src.User.FirstName + " " + src.User.LastName : null))
                .ForMember(dest => dest.UserMail, opt => opt.MapFrom(src => src.User != null ? src.User.Email : null));
            CreateMap<ReservationInsertRequest, Database.Reservation>();
            CreateMap<ReservationUpdateRequest, Database.Reservation>();
            CreateMap<Database.Recommendation, Model.Recommendation>().ReverseMap();
            CreateMap<Database.Table, Model.Table>();
            CreateMap<TableInsertRequest, Database.Table>();
            CreateMap<TableUpdateRequest, Database.Table>();
            CreateMap<Database.Inventory, Model.Inventory>().ForMember(dest => dest.ProductName, opt => opt.MapFrom(src => src.Product.Name));
            CreateMap<InventoryInsertRequest, Database.Inventory>();
            CreateMap<InventoryUpdateRequest, Database.Inventory>();
            CreateMap<Database.City, Model.City>();
            CreateMap<CityUpsertRequest, Database.City>();
        }
    }
}
