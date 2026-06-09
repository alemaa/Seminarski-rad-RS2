using AutoMapper;
using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Services.Database;
using System.Linq;

namespace CafeEase.Services.Mapping
{
    public class MappingProfile : Profile
    {
        private static void IgnoreNullValues<TSource, TDestination>(IMappingExpression<TSource, TDestination> map)
        {
            map.ForAllMembers(opt =>
            {
                opt.PreCondition((src, dest, context) =>
                {
                    var sourceProperty = typeof(TSource).GetProperty(opt.DestinationMember.Name);
                    return sourceProperty == null || sourceProperty.GetValue(src) != null;
                });
            });
        }

        public MappingProfile()
        {
            CreateMap<Database.User, Model.User>();
            CreateMap<Model.Requests.UserInsertRequest, Database.User>();
            CreateMap<Model.Requests.UserUpdateRequest, Database.User>();
            CreateMap<Model.Requests.RegisterRequest, Database.User>();
            CreateMap<Database.Category, Model.Category>();
            CreateMap<CategoryUpsertRequest, Database.Category>();
            CreateMap<Database.Product, Model.Product>();
            CreateMap<ProductInsertRequest, Database.Product>();
            IgnoreNullValues(CreateMap<ProductUpdateRequest, Database.Product>());
            CreateMap<OrderInsertRequest, Database.Order>();
            CreateMap<Database.Order, Model.Order>().ForMember(dest => dest.UserFullName, opt => opt.MapFrom(src => src.User.FirstName + " " + src.User.LastName))
             .ForMember(dest => dest.TableNumber, opt => opt.MapFrom(src => src.Table.Number)); ;
            CreateMap<Database.OrderItem, Model.OrderItem>().ForMember(dest => dest.ProductName, opt => opt.MapFrom(src => src.Product.Name));
            CreateMap<OrderItemInsertRequest, Database.OrderItem>();
            IgnoreNullValues(CreateMap<OrderItemUpdateRequest, Database.OrderItem>());
            CreateMap<Database.Payment, Model.Payment>();
            CreateMap<PaymentInsertRequest, Database.Payment>();
            IgnoreNullValues(CreateMap<PaymentUpdateRequest, Database.Payment>());
            CreateMap<Database.LoyaltyPoints, Model.LoyaltyPoints>();
            CreateMap<LoyaltyPointsInsertRequest, Database.LoyaltyPoints>();
            IgnoreNullValues(CreateMap<LoyaltyPointsUpdateRequest, Database.LoyaltyPoints>());
            CreateMap<Database.Promotion, Model.Promotion>().ForMember(dest => dest.Categories, opt => opt.MapFrom(src => src.PromotionCategories.Where(pc => pc.Category != null).Select(pc => pc.Category)));
            CreateMap<PromotionInsertRequest, Database.Promotion>();
            IgnoreNullValues(CreateMap<PromotionUpdateRequest, Database.Promotion>());
            CreateMap<Database.Review, Model.Review>().ForMember(d => d.UserFullName, o => o.MapFrom(s => s.User.FirstName + " " + s.User.LastName)).ForMember(d => d.ProductName, o => o.MapFrom(s => s.Product.Name));
            CreateMap<ReviewInsertRequest, Database.Review>();
            IgnoreNullValues(CreateMap<ReviewUpdateRequest, Database.Review>());
            CreateMap<Database.Reservation, Model.Reservation>().ForMember(dest => dest.TableNumber, opt => opt.MapFrom(src => src.Table.Number)).
                ForMember(dest => dest.UserFullName, opt => opt.MapFrom(src => src.User != null ? src.User.FirstName + " " + src.User.LastName : null))
                .ForMember(dest => dest.UserMail, opt => opt.MapFrom(src => src.User != null ? src.User.Email : null));
            CreateMap<ReservationInsertRequest, Database.Reservation>();
            IgnoreNullValues(CreateMap<ReservationUpdateRequest, Database.Reservation>());
            CreateMap<Database.Recommendation, Model.Recommendation>().ReverseMap();
            CreateMap<Database.Table, Model.Table>();
            CreateMap<TableInsertRequest, Database.Table>();
            CreateMap<TableUpdateRequest, Database.Table>();
            CreateMap<Database.Inventory, Model.Inventory>().ForMember(dest => dest.ProductName, opt => opt.MapFrom(src => src.Product.Name));
            CreateMap<InventoryInsertRequest, Database.Inventory>();
            IgnoreNullValues(CreateMap<InventoryUpdateRequest, Database.Inventory>());
            CreateMap<Database.City, Model.City>();
            CreateMap<CityUpsertRequest, Database.City>();
            CreateMap<Database.Notification, Model.Notification>();
            CreateMap<Database.Cafe, Model.Cafe>()
            .ForMember(dest => dest.CityName, opt => opt.MapFrom(src => src.City.Name));
            CreateMap<CafeEase.Model.Requests.CafeUpsertRequest, Database.Cafe>();
        }
    }
}
