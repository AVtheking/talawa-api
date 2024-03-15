import { logger } from "../../libraries";
import { UserFamily } from "../../models/userFamily";
import { QueryResolvers } from "../../types/generatedGraphQLTypes";

export const getUserFamily: QueryResolvers["getUserFamily"] = async (_parent, args) => {
    const userfamily = await UserFamily.findOne({
        users: args.id,
    })
    logger.info(`UserFamily: ${userfamily}`);
    return userfamily;
}